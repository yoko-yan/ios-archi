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

    private let onChanged: ((Coordinates?) -> Void)?

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

    init(coordinates: Coordinates? = nil, onChanged: ((Coordinates?) -> Void)? = nil) {
        _viewModel = StateObject(
            wrappedValue: CoordinatesEditViewModel(
                coordinatesX: coordinates?.text.components(separatedBy: ",")[0],
                coordinatesY: coordinates?.text.components(separatedBy: ",")[1],
                coordinatesZ: coordinates?.text.components(separatedBy: ",")[2]
            )
        )
        self.onChanged = onChanged
    }

//    init(coordinatesX: String?, coordinatesY: String?, coordinatesZ: String?, onChanged: ((String?) -> Void)? = nil) {
//        _viewModel = StateObject(
//            wrappedValue: CoordinatesEditViewModel(
//                coordinatesX: coordinatesX,
//                coordinatesY: coordinatesY,
//                coordinatesZ: coordinatesZ
//            )
//        )
//        self.onChanged = onChanged
//    }
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
                    }
                    .padding(.horizontal)

                    HStack {
                        TextField(
                            "X",
                            text: .init(
                                get: { viewModel.uiState.coordinatesX ?? "" },
                                set: { newValue in
                                    Task {
                                        await viewModel.send(action: .setCoordinatesX(newValue))
                                    }
                                }
                            )
                        )
                        .keyboardType(.numbersAndPunctuation)
                        .multilineTextAlignment(TextAlignment.trailing)
                        .modifier(
                            TextFieldClearButton(
                                text: .init(
                                    get: { viewModel.uiState.coordinatesX ?? "" },
                                    set: { newValue in
                                        Task {
                                            await viewModel.send(action: .setCoordinatesX(newValue))
                                        }
                                    }
                                )
                            )
                        )
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                        TextField(
                            "Y",
                            text: .init(
                                get: { viewModel.uiState.coordinatesY ?? "" },
                                set: { newValue in
                                    Task {
                                        await viewModel.send(action: .setCoordinatesY(newValue))
                                    }
                                }
                            )
                        )
                        .keyboardType(.numbersAndPunctuation)
                        .multilineTextAlignment(TextAlignment.trailing)
                        .modifier(
                            TextFieldClearButton(
                                text: .init(
                                    get: { viewModel.uiState.coordinatesY ?? "" },
                                    set: { newValue in
                                        Task {
                                            await viewModel.send(action: .setCoordinatesY(newValue))
                                        }
                                    }
                                )
                            )
                        )
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                        TextField(
                            "Z",
                            text: .init(
                                get: { viewModel.uiState.coordinatesZ ?? "" },
                                set: { newValue in
                                    Task {
                                        await viewModel.send(action: .setCoordinatesZ(newValue))
                                    }
                                }
                            )
                        )
                        .keyboardType(.numbersAndPunctuation)
                        .multilineTextAlignment(TextAlignment.trailing)
                        .modifier(
                            TextFieldClearButton(
                                text: .init(
                                    get: { viewModel.uiState.coordinatesZ ?? "" },
                                    set: { newValue in
                                        Task {
                                            await viewModel.send(action: .setCoordinatesZ(newValue))
                                        }
                                    }
                                )
                            )
                        )
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding(.horizontal)
                    .accentColor(.gray)

                    Spacer()
                }
                .navigationBarTitle("座標を変更する", displayMode: .inline)

                Button(action: {
                    let uiState = viewModel.uiState
                    onChanged?(
                        Coordinates(
                            x: Int(uiState.coordinatesX ?? "0") ?? 0,
                            y: Int(uiState.coordinatesY ?? "0") ?? 0,
                            z: Int(uiState.coordinatesZ ?? "0") ?? 0
                        )
                    )
                    dismiss()
                }) {
                    Text("変更する")
                        .bold()
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(RoundedButtonStyle(color: .black))
                .padding()
            }
        }
    }
}

// MARK: - Previews

// #Preview {
//    CoordinatesEditView(
//        coordinates: "318, 63, 1143"
//    )
// }
//
// #Preview {
//    CoordinatesEditView(
//        coordinates: nil
//    )
// }
