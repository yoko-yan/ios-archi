//
//  Created by yokoda.takayuki on 2023/01/25.
//

import SwiftUI
import UIKit

struct ImagePicker: UIViewControllerRepresentable {
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
            parent.image = info[.originalImage] as? UIImage
            parent.show.toggle()
        }
    }

    @Binding var show: Bool
    @Binding var image: UIImage?
    @Binding var sourceType: UIImagePickerController.SourceType

    func makeCoordinator() -> ImagePicker.Coordinator {
        Self.Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> some UIViewController {
        let controller = UIImagePickerController()
        controller.sourceType = sourceType
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_: UIViewControllerType, context _: Context) {}
}
