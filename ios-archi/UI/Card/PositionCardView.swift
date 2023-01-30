//
//  PositionCardView.swift
//  ios-archi
//
//  Created by yokoda.takayuki on 2023/01/29.
//

import Combine
import SwiftUI

struct PositionCardView: View {
    @Binding var position: Position?
    @Binding var image: UIImage?

    @State private var isImagePicker = false
    @State private var imageSourceType: UIImagePickerController.SourceType = .photoLibrary

    var body: some View {
        VStack {
            Spacer()
            VStack {
                HStack {
                    Label("position", systemImage: "location.circle")
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
                        Spacer()
                        Text("画像から座標を取得")
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
                HStack {
                    Text(position?.text ?? "Not Found")
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

struct PositionCardView_Previews: PreviewProvider {
    static var previews: some View {
        PositionCardView(
            position: .constant(.init(x: 200, y: 0, z: -100)),
            image: .constant(UIImage(named: "sample-position")!)
        )
    }
}
