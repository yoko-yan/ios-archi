import UIKit

/// カメラ画面のUI状態を管理するモデル
struct CustomCameraUiState: Equatable, Sendable {
    var capturedImage: UIImage?
    var isSessionRunning: Bool = false
    var flashEnabled: Bool = false
    var gridEnabled: Bool = false
    var shutterButtonPosition: CameraSettings.ShutterButtonPosition = .center
    var aspectRatio: CameraSettings.AspectRatio = .fill
    var zoomFactor: Double = 1.0
    var cameraPosition: CameraPosition = .back
    var error: CameraError?

    enum CameraPosition: Sendable {
        case front
        case back
    }

    enum CameraError: Error, Sendable, Equatable {
        case permissionDenied
        case deviceUnavailable
        case sessionConfigurationFailed
        case captureFailed
    }
}
