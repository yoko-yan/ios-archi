//
//  Created by yokoda.takayuki on 2023/01/29.
//

import Combine
import SwiftUI

struct CoordinatesEditView: View {
    @Binding var coordinates: Coordinates?
    @Binding var image: UIImage?

    @State private var isImagePicker = false
    @State private var imageSourceType: ImagePicker.SourceType = .library

    var body: some View {
        VStack {
            VStack {
                HStack {
                    Label("coordinates", systemImage: "location.circle")
                    Spacer()
                    TextField("未登録", text: .init(get: {
                        coordinates?.text ?? ""
                    }, set: { newValue in
                        coordinates = Coordinates(newValue)
                    }))
                    .multilineTextAlignment(TextAlignment.trailing)
                }
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
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
            }
            .padding(.horizontal)
            .accentColor(.gray)

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
    CoordinatesEditView(
        coordinates: .constant(.init(x: 200, y: 0, z: -100)),
        image: .constant(UIImage(named: "sample-coordinates", in: Bundle.module, with: nil)!)
    )
}

#Preview {
    CoordinatesEditView(
        coordinates: .constant(nil),
        image: .constant(nil)
    )
}
