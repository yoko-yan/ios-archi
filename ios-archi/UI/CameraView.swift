//
//  Camera.swift
//  ios-archi
//
//  Created by yokoda.takayuki on 2023/01/25.
//

import SwiftUI
import Vision
import VisionKit

struct CameraView: View {
    @State var imageData: Data = .init(capacity: 0)
    @State var source: UIImagePickerController.SourceType = .photoLibrary

    @State var isImagePicker = false
    private var requests = [VNRequest]()

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ZStack {
                    NavigationLink(
                        destination:
                            ImagePicker(
                                show: $isImagePicker,
                                image: $imageData,
                                sourceType: source
                            ),
                        isActive: $isImagePicker,
                        label: { Text("") }
                    )
                    VStack(spacing: 0) {
                        if imageData.count != 0{
                            Image(
                                uiImage: UIImage(data: self.imageData)!
                            )
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 250)
                            .cornerRadius(15)
                            .padding()
                        }
                        Button {
                            self.isImagePicker.toggle()
                        } label: {
                            Text("Take Photo")
                        }
                        BiomeFinderView(mapGotoX: 100, mapGotoZ: 200)
                    }
                }
            }
        }
    }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}
