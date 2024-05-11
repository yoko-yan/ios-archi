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
                    Text("Register a photo", bundle: .module)
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
                Text("If the coordinates are visible in the photo, they can be recognized", bundle: .module)
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
        image: UIImage(resource: .sampleCoordinates),
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
