//
//  SeedCardView.swift
//  ios-archi
//
//  Created by yokoda.takayuki on 2023/01/29.
//

import Combine
import SwiftUI

struct SeedCardView: View {
    @Binding var seed: Seed?
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
                    Label("seed", systemImage: "globe")
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
                        Spacer()
                        Text("画像からシード値を取得")
                        Spacer()
                    }
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
                    Text(seedText)
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
            .background(Color.white)
            .cornerRadius(8)
            .clipped()
            .shadow(color: .gray.opacity(0.7), radius: 5)
            .accessibilityElement()
            Spacer()
        }
        .padding(.horizontal, 8)
    }

    private var seedText: String {
        if let seed {
            if image != nil {
                return seed.text
            } else {
                return "not seed position text"
            }
        } else {
            return ""
        }
    }
}

struct SeedCardView_Previews: PreviewProvider {
    // swiftlint:disable force_unwrapping
    static var previews: some View {
        SeedCardView(
            seed: .constant(Seed(rawValue: 1234567890)),
            image: .constant(UIImage(named: "sample-seed")!)
        )
    }
    // swiftlint:enable force_unwrapping
}
