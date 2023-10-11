//
//  Created by apla on 2023/10/11
//

import SwiftUI

struct SpotImageView: View {
    @Binding var image: UIImage?
    @State private var isImagePicker = false
    @State private var imageSourceType: ImagePicker.SourceType = .library

    var body: some View {
        VStack {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                Button {
                    imageSourceType = .library
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
            }

            HStack {
                Spacer()
                Button(action: {
                    imageSourceType = .camera
                    isImagePicker.toggle()
                }) {
                    Image(systemName: "camera.circle.fill")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 30, height: 30)
                }

                Button(action: {
                    imageSourceType = .library
                    isImagePicker.toggle()
                }) {
                    Image(systemName: "photo.circle.fill")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 30, height: 30)
                }
            }
            .padding(.horizontal)
            .accentColor(.gray)
        }
        .sheet(isPresented: $isImagePicker) {
            ImagePicker(
                show: $isImagePicker,
                image: $image,
                sourceType: imageSourceType,
                allowsEditing: true
            )
        }
    }
}

#Preview {
    SpotImageView(
        image: .constant(UIImage(named: "sample-coordinates", in: Bundle.module, with: nil)!) // swiftlint:disable:this force_unwrapping
    )
}

#Preview {
    SpotImageView(
        image: .constant(nil)
    )
}
