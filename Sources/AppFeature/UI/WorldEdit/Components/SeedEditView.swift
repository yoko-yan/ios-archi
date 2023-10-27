//
//  Created by yokoda.takayuki on 2023/01/29.
//

import Combine
import SwiftUI

struct SeedEditView: View {
    @Binding var seed: Seed?
    @Binding var image: UIImage?

    @State private var isImagePicker = false
    @State private var imageSourceType: ImagePicker.SourceType = .library

    var body: some View {
        VStack {
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
                        Text("写真からシード値を取得")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .contentShape(Rectangle())
                    .frame(height: 200)
                    .background(
                        Color.gray
                            .opacity(0.1)
                    )
                }
            }
            .accentColor(.gray)

            HStack {
                Text("写真にシード値が写っている場合、そのシード値を取得できます")
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

            HStack {
                Label("seed", systemImage: "globe.desk")
                Spacer()
                TextField(
                    "未登録",
                    text: .init(
                        get: { seed?.text ?? "" },
                        set: { newValue in seed = Seed(newValue) }
                    )
                )
                .keyboardType(.numberPad)
                .multilineTextAlignment(TextAlignment.trailing)
                .modifier(
                    TextFieldClearButton(
                        text: .init(
                            get: { seed?.text ?? "" },
                            set: { newValue in seed = Seed(newValue) }
                        )
                    )
                )
                .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding(.horizontal)
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

// MARK: - Previews

#Preview {
    SeedEditView(
        seed: .constant(nil),
        image: .constant(UIImage(resource: .sampleSeed))
    )
}

#Preview {
    SeedEditView(
        seed: .constant(nil),
        image: .constant(nil)
    )
}
