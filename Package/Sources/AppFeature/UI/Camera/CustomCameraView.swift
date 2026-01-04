import SwiftUI

/// カスタムカメラのメインView
struct CustomCameraView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var capturedImage: UIImage?
    @Binding var show: Bool

    @State private var viewModel = CustomCameraViewModel()
    @State private var lastZoomFactor: Double = 1.0
    @State private var showImageEdit = false
    @State private var capturedImageForEdit: UIImage?

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            // カメラプレビュー
            if viewModel.uiState.isSessionRunning {
                GeometryReader { geometry in
                    CameraPreviewView(
                        session: viewModel.captureSession,
                        aspectRatio: viewModel.uiState.aspectRatio
                    )
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                let newZoom = lastZoomFactor * value
                                viewModel.setZoom(newZoom)
                            }
                            .onEnded { value in
                                lastZoomFactor *= value
                            }
                    )
                    .frame(
                        width: previewWidth(for: viewModel.uiState.aspectRatio, geometry: geometry),
                        height: previewHeight(for: viewModel.uiState.aspectRatio, geometry: geometry)
                    )
                    .clipped()
                    .frame(maxHeight: .infinity)
                    .ignoresSafeArea()
                }
                .ignoresSafeArea()
                .transition(.identity)
            }

            // グリッド表示
            if viewModel.uiState.gridEnabled {
                GeometryReader { geometry in
                    GridOverlay()
                        .frame(
                            width: previewWidth(for: viewModel.uiState.aspectRatio, geometry: geometry),
                            height: previewHeight(for: viewModel.uiState.aspectRatio, geometry: geometry)
                        )
                        .frame(maxHeight: .infinity)
                }
                .ignoresSafeArea()
            }

            // カメラコントロール
            CameraControlsView(
                shutterButtonPosition: viewModel.uiState.shutterButtonPosition,
                flashEnabled: viewModel.uiState.flashEnabled,
                gridEnabled: viewModel.uiState.gridEnabled,
                aspectRatio: viewModel.uiState.aspectRatio,
                onCapture: {
                    viewModel.capturePhoto()
                },
                onToggleFlash: {
                    viewModel.toggleFlash()
                },
                onToggleGrid: {
                    viewModel.toggleGrid()
                },
                onToggleAspectRatio: {
                    viewModel.toggleAspectRatio()
                },
                onSwitchCamera: {
                    viewModel.switchCamera()
                },
                onClose: {
                    dismiss()
                }
            )

            // エラー表示
            if let error = viewModel.uiState.error {
                VStack {
                    Text(errorMessage(for: error))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(8)
                }
            }
        }
        .transaction { transaction in
            transaction.animation = nil
        }
        .task {
            await viewModel.setupCamera()
        }
        .onDisappear {
            viewModel.stopSession()
        }
        .onChange(of: viewModel.uiState.capturedImage) { _, newImage in
            if let newImage {
                capturedImageForEdit = newImage
                showImageEdit = true
            }
        }
        .fullScreenCover(isPresented: $showImageEdit) {
            if let image = capturedImageForEdit {
                ImageEditView(
                    image: image,
                    aspectRatio: viewModel.uiState.aspectRatio,
                    onSave: { editedImage in
                        capturedImage = editedImage
                        dismiss()
                    },
                    onCancel: {
                        capturedImageForEdit = nil
                        showImageEdit = false
                        Task {
                            // カメラを再開
                            await viewModel.setupCamera()
                        }
                    },
                    initialAspectRatio: viewModel.uiState.aspectRatio
                )
                .transaction { transaction in
                    transaction.disablesAnimations = true
                }
            }
        }
    }

    private func previewWidth(
        for aspectRatio: CameraSettings.AspectRatio,
        geometry: GeometryProxy
    ) -> CGFloat? {
        switch aspectRatio {
        case .square, .widescreen:
            return geometry.size.width
        case .fill, .fit, .stretch:
            return nil
        }
    }

    private func previewHeight(
        for aspectRatio: CameraSettings.AspectRatio,
        geometry: GeometryProxy
    ) -> CGFloat? {
        switch aspectRatio {
        case .square:
            return geometry.size.width
        case .widescreen:
            // 16:9 アスペクト比
            return geometry.size.width * 9 / 16
        case .fill, .fit, .stretch:
            return nil
        }
    }

    private func errorMessage(for error: CustomCameraUiState.CameraError) -> String {
        switch error {
        case .permissionDenied:
            return "カメラへのアクセスが拒否されました。設定から許可してください。"
        case .deviceUnavailable:
            return "カメラデバイスが利用できません。"
        case .sessionConfigurationFailed:
            return "カメラの設定に失敗しました。"
        case .captureFailed:
            return "写真の撮影に失敗しました。"
        }
    }
}

/// グリッド表示用のオーバーレイ
private struct GridOverlay: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height

                // 縦線
                path.move(to: CGPoint(x: width / 3, y: 0))
                path.addLine(to: CGPoint(x: width / 3, y: height))

                path.move(to: CGPoint(x: width * 2 / 3, y: 0))
                path.addLine(to: CGPoint(x: width * 2 / 3, y: height))

                // 横線
                path.move(to: CGPoint(x: 0, y: height / 3))
                path.addLine(to: CGPoint(x: width, y: height / 3))

                path.move(to: CGPoint(x: 0, y: height * 2 / 3))
                path.addLine(to: CGPoint(x: width, y: height * 2 / 3))
            }
            .stroke(Color.white.opacity(0.5), lineWidth: 1)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    CustomCameraView(
        capturedImage: .constant(nil),
        show: .constant(true)
    )
}
