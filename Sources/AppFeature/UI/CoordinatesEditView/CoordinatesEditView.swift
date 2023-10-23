//
//  Created by yoko-yan on 2023/10/15
//

import SwiftUI

struct CoordinatesEditView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: CoordinatesEditViewModel

    @State private var isImagePicker = false
    @State private var imageSourceType = ImagePicker.SourceType.library

    private let onChanged: ((String?) -> Void)?

    var body: some View {
        coordinatesEditCell
            .sheet(isPresented: $isImagePicker) {
                ImagePicker(
                    show: $isImagePicker,
                    image: .init(
                        get: { viewModel.uiState.coordinatesImage },
                        set: { newValue in
                            guard let newValue else { return }
                            Task {
                                await viewModel.send(action: .setCoordinatesImage(newValue))
                                await viewModel.send(action: .getCoordinates(from: newValue))
                            }
                        }
                    ),
                    sourceType: imageSourceType,
                    allowsEditing: true
                )
            }
    }

    init(coordinates: String? = nil, onChanged: ((String?) -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: CoordinatesEditViewModel(coordinates: coordinates))
        self.onChanged = onChanged
    }
}

// MARK: - Privates

private extension CoordinatesEditView {
    var coordinatesEditCell: some View {
        ZStack {
            ScrollView {
                VStack {
                    if let image = viewModel.uiState.coordinatesImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                    } else {
                        Button {
                            imageSourceType = .library
                            isImagePicker.toggle()
                        } label: {
                            Text("写真から座標を取得")
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

                    HStack {
                        Label("coordinates", systemImage: "location.circle")
                        Spacer()
                        TextField(
                            "未登録",
                            text: .init(
                                get: { viewModel.uiState.coordinates ?? "" },
                                set: { newValue in
                                    Task {
                                        await viewModel.send(action: .setCoordinates(newValue))
                                    }
                                }
                            )
                        )
                        .keyboardType(.numbersAndPunctuation)
                        .multilineTextAlignment(TextAlignment.trailing)
                    }
                    .padding(.horizontal)
                    .accentColor(.gray)

                    Spacer()
                }
                .navigationBarTitle("座標を変更する", displayMode: .inline)

                footer
            }
        }
    }

    var footer: some View {
        VStack {
            Spacer()
            HStack {
                if (viewModel.uiState.coordinates?.isEmpty) != nil {
                    Button(action: {
                        Task {
                            await
                                viewModel.send(action: .setCoordinates(nil))
                            onChanged?(nil)
                            dismiss()
                        }
                    }) {
                        Text("クリアする")
                            .bold()
                            .frame(height: 50)
                            .padding(.horizontal)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                    }
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                }

                Button(action: {
                    onChanged?(viewModel.uiState.coordinates)
                    dismiss()
                }) {
                    Text("変更する")
                        .bold()
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(RoundedButtonStyle(color: .black))
            }
        }
        .padding()
    }
}

// MARK: - Previews

#Preview {
    CoordinatesEditView(
        coordinates: "318, 63, 1143"
    )
}

#Preview {
    CoordinatesEditView(
        coordinates: nil
    )
}
