//
//  ImagePicker.swift
//  ios-archi
//
//  Created by yokoda.takayuki on 2023/01/25.
//

import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var show: Bool
    @Binding var image: Data
    var sourceType: UIImagePickerController.SourceType

    func makeCoordinator() -> ImagePicker.Coodinator {
        return ImagePicker.Coodinator(parent: self)
    }

    func makeUIViewController(context: Context) -> some UIViewController {
        let controller = UIImagePickerController()
        controller.sourceType = sourceType
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}

    class Coodinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

        var parent: ImagePicker

        init(parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            self.parent.show.toggle()
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

            let image = info[.originalImage] as! UIImage
            let data = image.pngData()
            self.parent.image = data!
            self.parent.show.toggle()
        }
    }
}
