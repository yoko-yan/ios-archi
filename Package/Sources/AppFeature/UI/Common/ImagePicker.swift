import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    enum SourceType {
        case camera
        case library
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePicker

        init(parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerControllerDidCancel(_: UIImagePickerController) {
            parent.onCancel?()
            if parent.dismissOnPick {
                parent.show.toggle()
            }
        }

        func imagePickerController(
            _: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            let pickedImage: UIImage?
            if parent.allowsEditing {
                pickedImage = info[.editedImage] as? UIImage
            } else {
                pickedImage = info[.originalImage] as? UIImage
            }

            let normalizedImage = pickedImage?
                .normalizedImage()?
                .resized(toMaxSizeKB: 1000.0)
            parent.image = normalizedImage
            if let normalizedImage {
                parent.onPicked?(normalizedImage)
            }
            if parent.dismissOnPick {
                parent.show.toggle()
            }
        }
    }

    @Binding var show: Bool
    @Binding var image: UIImage?
    var sourceType: SourceType
    var allowsEditing = false
    var dismissOnPick = true
    var onPicked: ((UIImage) -> Void)?
    var onCancel: (() -> Void)?

    func makeCoordinator() -> Self.Coordinator {
        Self.Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> some UIViewController {
        // FIXME: UIImagePickerControllerからフォトライブラリへのアクセスはiOS14でdeprecatedなのでPHPickerViewControllerにする
        let controller = UIImagePickerController()
        switch sourceType {
        case .camera:
            controller.sourceType = UIImagePickerController.SourceType.camera
        case .library:
            controller.sourceType = UIImagePickerController.SourceType.photoLibrary
        }
        controller.delegate = context.coordinator
        controller.allowsEditing = allowsEditing
        return controller
    }

    func updateUIViewController(_: UIViewControllerType, context _: Context) {}
}
