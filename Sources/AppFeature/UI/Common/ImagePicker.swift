//
//  Created by yokoda.takayuki on 2023/01/25.
//

import SwiftUI
import UIKit

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
            parent.show.toggle()
        }

        func imagePickerController(
            _: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            let image = info[.editedImage] as? UIImage
            parent.image = image?.normalizedImage()
            parent.show.toggle()
        }
    }

    @Binding var show: Bool
    @Binding var image: UIImage?
    var sourceType: SourceType
    var allowsEditing = false

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
