//
//  Created by apla on 2023/10/11
//

import SwiftUI

struct SpotImageEditCell: View {
    let image: UIImage?
    @Binding var isImagePicker: Bool
    @Binding var imageSourceType: ImagePicker.SourceType

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
                    Text("写真を登録")
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
                Text("写真に座標が写っている場合、その座標を取得できます")
                    .font(.caption2)
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
    }
}

// MARK: - Previews

#Preview {
    SpotImageEditCell(
        image: UIImage(named: "sample-coordinates", in: Bundle.module, with: nil)!,
        isImagePicker: .constant(false),
        imageSourceType: .constant(.library)
    )
}

#Preview {
    SpotImageEditCell(
        image: nil,
        isImagePicker: .constant(false),
        imageSourceType: .constant(.library)
    )
}
