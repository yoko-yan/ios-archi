import SwiftUI

struct SpotImageEditCell: View {
    let image: UIImage?
    @Binding var imagePickerState: ItemEditView.ImagePickerState

    var body: some View {
        VStack {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                Button {
                    imagePickerState = .library
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
                    imagePickerState = .camera
                }) {
                    Image(systemName: "camera.circle.fill")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 30, height: 30)
                }

                Button(action: {
                    imagePickerState = .library
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
        imagePickerState: .constant(.hidden)
    )
}

#Preview {
    SpotImageEditCell(
        image: nil,
        imagePickerState: .constant(.hidden)
    )
}
