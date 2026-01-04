import Dependencies
import SwiftUI

/// ImagePickerとCustomCameraViewを切り替えるアダプター
///
/// カメラモードの場合、カスタムカメラ（CustomCameraView）または
/// システムカメラ（UIImagePickerController）を切り替えることができます。
/// フォトライブラリモードの場合は常にUIImagePickerControllerを使用します。
struct ImagePickerAdapter: View {
    enum SourceType {
        case camera
        case library
    }

    enum CameraMode {
        /// カスタムカメラを使用（CustomCameraView）
        case custom
        /// システムカメラを使用（UIImagePickerController）
        case system
    }

    @Binding var show: Bool
    @Binding var image: UIImage?
    var sourceType: SourceType
    var allowsEditing = false
    var cameraMode: CameraMode = .custom
    @State private var pendingImage: UIImage?
    @State private var showImageEdit = false
    @State private var cameraAspectRatio: CameraSettings.AspectRatio = .square

    @ObservationIgnored
    @Dependency(\.getCameraSettingsUseCase) private var getCameraSettings

    @ViewBuilder
    var body: some View {
        if sourceType == .camera, cameraMode == .custom {
            // カスタムカメラを使用
            CustomCameraView(
                capturedImage: $image,
                show: $show
            )
        } else if sourceType == .library {
            ImagePicker(
                show: $show,
                image: $pendingImage,
                sourceType: .library,
                allowsEditing: false,
                dismissOnPick: false,
                onPicked: { newImage in
                    pendingImage = newImage
                    showImageEdit = true
                },
                onCancel: {
                    show = false
                }
            )
            .fullScreenCover(isPresented: $showImageEdit) {
                if let pendingImage {
                    ImageEditView(
                        image: pendingImage,
                        onSave: { editedImage in
                            image = editedImage
                            showImageEdit = false
                            self.pendingImage = nil
                            show = false
                        },
                        onCancel: {
                            showImageEdit = false
                            self.pendingImage = nil
                        },
                        cancelButtonTitle: "再選択",
                        initialAspectRatio: cameraAspectRatio
                    )
                    .transaction { transaction in
                        transaction.disablesAnimations = true
                    }
                }
            }
            .onChange(of: show) { _, newValue in
                if !newValue {
                    showImageEdit = false
                    pendingImage = nil
                }
            }
            .task {
                do {
                    let settings = try await getCameraSettings.execute()
                    cameraAspectRatio = settings.aspectRatio
                } catch {
                    cameraAspectRatio = .square
                }
            }
        } else {
            // システムのImagePickerを使用
            ImagePicker(
                show: $show,
                image: $image,
                sourceType: sourceType == .camera ? .camera : .library,
                allowsEditing: allowsEditing
            )
        }
    }
}

#Preview("カスタムカメラモード") {
    ImagePickerAdapter(
        show: .constant(true),
        image: .constant(nil),
        sourceType: .camera,
        cameraMode: .custom
    )
}

#Preview("システムカメラモード") {
    ImagePickerAdapter(
        show: .constant(true),
        image: .constant(nil),
        sourceType: .camera,
        cameraMode: .system
    )
}

#Preview("フォトライブラリモード") {
    ImagePickerAdapter(
        show: .constant(true),
        image: .constant(nil),
        sourceType: .library
    )
}
