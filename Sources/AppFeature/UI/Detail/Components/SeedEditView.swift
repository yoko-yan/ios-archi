//
//  SeedEditView.swift
//  ios-archi
//
//  Created by yokoda.takayuki on 2023/01/29.
//

import Combine
import SwiftUI

struct SeedEditView: View {
    @Binding var seed: Seed?
    @Binding var image: UIImage?

    @State private var isImagePicker = false
    @State private var imageSourceType: UIImagePickerController.SourceType = .photoLibrary

    var body: some View {
        VStack {
            if let image {
                SeedView(
                    seed: seed,
                    image: image
                )
            } else {
                VStack {
                    HStack {
                        Label("seed", systemImage: "globe")
                        Spacer()
                        Text(seed?.text ?? "未登録")
                            .bold()
                    }
                    Button {
                        imageSourceType = .photoLibrary
                        isImagePicker.toggle()
                    } label: {
                        Text("画像からシード値を取得")
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
                .accentColor(.gray)
                .padding()
            }

            HStack {
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
            .padding()
            .accentColor(.gray)
        }
    }
}

struct SeedEditView_Previews: PreviewProvider {
    // swiftlint:disable force_unwrapping
    static var previews: some View {
        SeedEditView(
            seed: .constant(Seed(rawValue: 1234567890)),
            image: .constant(UIImage(named: "sample-seed", in: Bundle.module, with: nil)!)
        )
        SeedEditView(
            seed: .constant(nil),
            image: .constant(nil)
        )
    }
    // swiftlint:enable force_unwrapping
}
