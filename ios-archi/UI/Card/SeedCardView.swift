//
//  SeedCardView.swift
//  ios-archi
//
//  Created by yokoda.takayuki on 2023/01/29.
//

import Combine
import SwiftUI

struct SeedCardView: View {
    @Binding var seed: Seed
    @Binding var image: UIImage?

    @State private var isImagePicker = false
    @State private var imageSourceType: UIImagePickerController.SourceType = .photoLibrary

    var body: some View {
        VStack {
            Spacer()
            VStack {
                HStack {
                    Label("seed", systemImage: "globe.asia.australia")
                    Spacer()
                }
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                } else {
                    Button {
                        self.imageSourceType = .photoLibrary
                        self.isImagePicker.toggle()
                    } label: {
                        Text("画像からシード値を取得")
                    }
                    .frame(height: 200)
                    .sheet(isPresented: $isImagePicker) {
                        ImagePicker(
                            show: $isImagePicker,
                            image: $image,
                            sourceType: $imageSourceType
                        )
                    }
                }
                HStack {
                    Text(seed.text)
                        .bold()
                    Spacer()
                    Button(action: {
                        self.imageSourceType = .camera
                        self.isImagePicker.toggle()
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
                        self.imageSourceType = .photoLibrary
                        self.isImagePicker.toggle()
                    }) {
                        Image(systemName: "photo.circle")
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
            }
            .padding()
            .accentColor(.gray)
            .background(Color.white)
            .cornerRadius(8)
            .clipped()
            .shadow(color: .gray.opacity(0.7), radius: 5)
            Spacer()
        }
        .padding()
    }
}

struct SeedCardView_Previews: PreviewProvider {
    static var previews: some View {
        SeedCardView(
            seed: .constant(Seed(rawValue: 1_234_567_890)),
            image: .constant(UIImage(named: "sample-seed")!)
        )
    }
}
