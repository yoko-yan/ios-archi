import AVFoundation
import Dependencies
import UIKit

@MainActor
@Observable
final class CustomCameraViewModel {
    private(set) var uiState: CustomCameraUiState

    @ObservationIgnored
    @Dependency(\.getCameraSettingsUseCase) private var getCameraSettings

    let captureSession = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private let sessionQueue = DispatchQueue(label: "camera.session")

    private var currentDevice: AVCaptureDevice?
    private var photoCaptureDelegate: PhotoCaptureDelegate?

    init() {
        uiState = CustomCameraUiState()
    }

    // MARK: - Camera Setup

    func setupCamera() async {
        // カメラ権限チェック
        guard await checkCameraPermission() else {
            uiState.error = .permissionDenied
            return
        }

        // 設定を読み込み
        do {
            let settings = try await getCameraSettings.execute()
            uiState.flashEnabled = settings.flashEnabled
            uiState.gridEnabled = settings.gridEnabled
            uiState.shutterButtonPosition = settings.shutterButtonPosition
            uiState.aspectRatio = settings.aspectRatio
            uiState.zoomFactor = settings.zoomFactor
        } catch {
            print("Failed to load camera settings: \(error)")
        }

        // カメラセッション設定
        sessionQueue.async { [weak self] in
            guard let self else { return }
            configureCaptureSession()
        }
    }

    private func configureCaptureSession() {
        captureSession.beginConfiguration()

        // デバイスを取得
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            Task { @MainActor in
                uiState.error = .deviceUnavailable
            }
            captureSession.commitConfiguration()
            return
        }

        currentDevice = device

        // デバイス入力を追加
        do {
            let input = try AVCaptureDeviceInput(device: device)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
        } catch {
            Task { @MainActor in
                uiState.error = .sessionConfigurationFailed
            }
            captureSession.commitConfiguration()
            return
        }

        // 写真出力を追加
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }

        captureSession.commitConfiguration()

        // セッション開始
        captureSession.startRunning()

        Task { @MainActor in
            uiState.isSessionRunning = true
        }
    }

    // MARK: - Camera Permission

    private func checkCameraPermission() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return true
        case .notDetermined:
            return await AVCaptureDevice.requestAccess(for: .video)
        case .denied, .restricted:
            return false
        @unknown default:
            return false
        }
    }

    // MARK: - Camera Controls

    func capturePhoto() {
        let settings = AVCapturePhotoSettings()

        // フラッシュ設定
        if uiState.flashEnabled, currentDevice?.hasFlash == true {
            settings.flashMode = .on
        } else {
            settings.flashMode = .off
        }

        // デリゲートを保持する
        photoCaptureDelegate = PhotoCaptureDelegate { [weak self] image in
            Task { @MainActor [weak self] in
                guard let self else { return }

                // アスペクト比が正方形の場合、画像を正方形にクロップ
                if uiState.aspectRatio == .square, let squareImage = cropToSquare(image) {
                    uiState.capturedImage = squareImage
                } else {
                    uiState.capturedImage = image
                }

                // 撮影完了後にデリゲートをクリア
                photoCaptureDelegate = nil
            }
        }

        photoOutput.capturePhoto(with: settings, delegate: photoCaptureDelegate!)
    }

    /// 画像を正方形にクロップ（画像の向きを考慮）
    private func cropToSquare(_ image: UIImage?) -> UIImage? {
        guard let image else { return nil }

        // 画像の向きを考慮したサイズ
        let imageSize = image.size
        let shortSide = min(imageSize.width, imageSize.height)

        // 中央を基準に正方形の領域を計算
        let cropRect = CGRect(
            x: (imageSize.width - shortSide) / 2,
            y: (imageSize.height - shortSide) / 2,
            width: shortSide,
            height: shortSide
        )

        // UIGraphicsImageRendererを使用して、画像の向きを考慮してクロップ
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: shortSide, height: shortSide))
        return renderer.image { _ in
            // 画像全体を描画してから、必要な部分だけを切り出す
            image.draw(at: CGPoint(x: -cropRect.origin.x, y: -cropRect.origin.y))
        }
    }

    func toggleFlash() {
        uiState.flashEnabled.toggle()
    }

    func toggleGrid() {
        uiState.gridEnabled.toggle()
    }

    func toggleAspectRatio() {
        // 正方形とワイドを切り替え
        uiState.aspectRatio = uiState.aspectRatio == .square ? .widescreen : .square
    }

    func switchCamera() {
        sessionQueue.async { [weak self] in
            guard let self else { return }

            captureSession.beginConfiguration()

            // 現在の入力を削除
            if let currentInput = captureSession.inputs.first as? AVCaptureDeviceInput {
                captureSession.removeInput(currentInput)
            }

            // カメラ位置を切り替え
            let newPosition: AVCaptureDevice.Position = uiState.cameraPosition == .back ? .front : .back

            guard let newDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition) else {
                captureSession.commitConfiguration()
                return
            }

            currentDevice = newDevice

            do {
                let newInput = try AVCaptureDeviceInput(device: newDevice)
                if captureSession.canAddInput(newInput) {
                    captureSession.addInput(newInput)
                }
            } catch {
                print("Failed to switch camera: \(error)")
                captureSession.commitConfiguration()
                return
            }

            captureSession.commitConfiguration()

            Task { @MainActor in
                self.uiState.cameraPosition = newPosition == .back ? .back : .front
            }
        }
    }

    func stopSession() {
        sessionQueue.async { [weak self] in
            self?.captureSession.stopRunning()
        }
    }

    // MARK: - Exposure Control

    func setExposureMode(_ mode: CameraSettings.ExposureMode) {
        guard let device = currentDevice else { return }

        do {
            try device.lockForConfiguration()

            switch mode {
            case .auto:
                if device.isExposureModeSupported(.continuousAutoExposure) {
                    device.exposureMode = .continuousAutoExposure
                }
            case .manual:
                if device.isExposureModeSupported(.custom) {
                    device.exposureMode = .custom
                }
            }

            device.unlockForConfiguration()
        } catch {
            print("Failed to set exposure mode: \(error)")
        }
    }

    func adjustExposure(value: Float) {
        guard let device = currentDevice else { return }

        do {
            try device.lockForConfiguration()

            // 露出補正値を設定（-2.0 〜 2.0）
            let clampedValue = max(device.minExposureTargetBias, min(value, device.maxExposureTargetBias))
            device.setExposureTargetBias(clampedValue, completionHandler: nil)

            device.unlockForConfiguration()
        } catch {
            print("Failed to adjust exposure: \(error)")
        }
    }

    // MARK: - Focus Control

    func setFocusMode(_ mode: CameraSettings.FocusMode) {
        guard let device = currentDevice else { return }

        do {
            try device.lockForConfiguration()

            switch mode {
            case .auto:
                if device.isFocusModeSupported(.continuousAutoFocus) {
                    device.focusMode = .continuousAutoFocus
                }
            case .manual:
                if device.isFocusModeSupported(.locked) {
                    device.focusMode = .locked
                }
            }

            device.unlockForConfiguration()
        } catch {
            print("Failed to set focus mode: \(error)")
        }
    }

    func adjustFocus(value: Float) {
        guard let device = currentDevice else { return }

        do {
            try device.lockForConfiguration()

            // フォーカス位置を設定（0.0 〜 1.0）
            let clampedValue = max(0.0, min(value, 1.0))
            device.setFocusModeLocked(lensPosition: clampedValue, completionHandler: nil)

            device.unlockForConfiguration()
        } catch {
            print("Failed to adjust focus: \(error)")
        }
    }

    // MARK: - Zoom Control

    func setZoom(_ factor: Double) {
        guard let device = currentDevice else { return }

        do {
            try device.lockForConfiguration()

            // ズーム倍率を設定（1.0 〜 デバイスの最大値）
            let clampedFactor = max(1.0, min(factor, device.activeFormat.videoMaxZoomFactor))
            device.videoZoomFactor = clampedFactor

            device.unlockForConfiguration()

            Task { @MainActor in
                uiState.zoomFactor = clampedFactor
            }
        } catch {
            print("Failed to set zoom: \(error)")
        }
    }
}

// MARK: - PhotoCaptureDelegate

private class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    private let completion: (UIImage?) -> Void

    init(completion: @escaping (UIImage?) -> Void) {
        self.completion = completion
    }

    func photoOutput(
        _: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        if let error {
            print("Error capturing photo: \(error)")
            completion(nil)
            return
        }

        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData)
        else {
            completion(nil)
            return
        }

        completion(image)
    }
}
