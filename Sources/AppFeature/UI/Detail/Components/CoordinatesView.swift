//
//  CoordinatesView.swift
//  ios-archi
//
//  Created by yokoda.takayuki on 2023/01/29.
//

import Combine
import SwiftUI

struct CoordinatesView: View {
    @Binding var coordinates: Coordinates?
    @Binding var image: UIImage?

    @State private var isImagePicker = false
    @State private var imageSourceType: UIImagePickerController.SourceType = .photoLibrary

    var body: some View {
        // swiftlint:disable:next closure_body_length
        VStack {
            Spacer()
            // swiftlint:disable:next closure_body_length
            VStack {
                HStack {
                    Label("coordinates", systemImage: "location.circle")
                    Spacer()
                }
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                } else {
                    Button {
                        imageSourceType = .photoLibrary
                        isImagePicker.toggle()
                    } label: {
                        Text("画像から座標を取得")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .contentShape(Rectangle())
                    .frame(height: 200)
                    .background(
                        Color.gray
                            .opacity(0.1)
                    )
                    .sheet(isPresented: $isImagePicker) {
                        ImagePicker(
                            show: $isImagePicker,
                            image: $image,
                            sourceType: $imageSourceType
                        )
                    }
                }
                // swiftlint:disable:next closure_body_length
                HStack {
                    Text(coordinates?.text ?? "")
                        .bold()
                    Spacer()
                    Button(action: {
                        imageSourceType = .camera
                        isImagePicker.toggle()
                    }) {
                        Image(systemName: "camera.circle")
                            .resizable()
                            .frame(width: 30, height: 30)
                    }
                    .sheet(isPresented: $isImagePicker) {
                        ImagePicker(
                            show: $isImagePicker,
                            image: $image,
                            sourceType: $imageSourceType
                        )
                    }

                    Button(action: {
                        imageSourceType = .photoLibrary
                        isImagePicker.toggle()
                    }) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .resizable()
                            .frame(width: 30, height: 30)
                    }
                    .sheet(isPresented: $isImagePicker) {
                        ImagePicker(
                            show: $isImagePicker,
                            image: $image,
                            sourceType: $imageSourceType
                        )
                    }
                }
                .frame(height: 40)
            }
            .padding()
            .accentColor(.gray)
        }
        .padding(.horizontal, 8)
    }
}

struct CoordinatesCardView_Previews: PreviewProvider {
    // swiftlint:disable force_unwrapping
    static var previews: some View {
        CoordinatesView(
            coordinates: .constant(.init(x: 200, y: 0, z: -100)),
            image: .constant(UIImage(named: "sample-coordinates", in: Bundle.module, with: nil)!)
        )
        CoordinatesView(
            coordinates: .constant(nil),
            image: .constant(nil)
        )
    }
    // swiftlint:enable force_unwrapping
}
