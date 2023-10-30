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

    private let onChanged: ((Coordinates?) -> Bool)?

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

    init(coordinates: Coordinates?, onChanged: ((Coordinates?) -> Bool)? = nil) {
        _viewModel = StateObject(
            wrappedValue: CoordinatesEditViewModel(coordinates: coordinates)
        )
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
                    }
                    .padding(.horizontal)

                    HStack {
                        TextField(
                            "X",
                            text: .init(
                                get: { viewModel.uiState.coordinatesX },
                                set: { newValue in
                                    Task {
                                        await viewModel.send(action: .setCoordinatesX(newValue))
                                    }
                                }
                            )
                        )
                        .keyboardType(.numbersAndPunctuation)
                        .multilineTextAlignment(TextAlignment.leading)
                        .modifier(
                            TextFieldClearButton(
                                text: .init(
                                    get: { viewModel.uiState.coordinatesX },
                                    set: { newValue in
                                        Task {
                                            await viewModel.send(action: .setCoordinatesX(newValue))
                                        }
                                    }
                                )
                            )
                        )
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .layoutPriority(1)

                        TextField(
                            "Y",
                            text: .init(
                                get: { viewModel.uiState.coordinatesY },
                                set: { newValue in
                                    Task {
                                        await viewModel.send(action: .setCoordinatesY(newValue))
                                    }
                                }
                            )
                        )
                        .keyboardType(.numbersAndPunctuation)
                        .multilineTextAlignment(TextAlignment.leading)
                        .modifier(
                            TextFieldClearButton(
                                text: .init(
                                    get: { viewModel.uiState.coordinatesY },
                                    set: { newValue in
                                        Task {
                                            await viewModel.send(action: .setCoordinatesY(newValue))
                                        }
                                    }
                                )
                            )
                        )
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .layoutPriority(1)

                        TextField(
                            "Z",
                            text: .init(
                                get: { viewModel.uiState.coordinatesZ },
                                set: { newValue in
                                    Task {
                                        await viewModel.send(action: .setCoordinatesZ(newValue))
                                    }
                                }
                            )
                        )
                        .keyboardType(.numbersAndPunctuation)
                        .multilineTextAlignment(TextAlignment.leading)
                        .modifier(
                            TextFieldClearButton(
                                text: .init(
                                    get: { viewModel.uiState.coordinatesZ },
                                    set: { newValue in
                                        Task {
                                            await viewModel.send(action: .setCoordinatesZ(newValue))
                                        }
                                    }
                                )
                            )
                        )
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .layoutPriority(1)
                    }
                    .padding(.horizontal)
                    .accentColor(.gray)

                    Spacer()
                }

                if !viewModel.uiState.validationErrors.isEmpty {
                    HStack {
                        VStack {
                            ForEach(viewModel.uiState.validationErrors, id: \.self) { validationError in
                                Text(validationError.localizedDescription)
                                    .font(.caption2)
                                    .bold()
                                    .foregroundColor(.red)
                            }
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                }

                HStack {
                    if viewModel.uiState.coordinates != nil {
                        Button(action: {
                            Task {
                                await viewModel.send(action: .clearCoordinates)
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
                        Task {
                            await viewModel.send(action: .onChangeButtonTap)
                        }
                    }) {
                        Text("変更する")
                            .bold()
                            .frame(height: 50)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(RoundedButtonStyle(color: .black))
                }
                .padding()
            }
        }
        .navigationBarTitle("座標を変更する", displayMode: .inline)
        .onChange(of: viewModel.uiState.events) { [old = viewModel.uiState.events] new in
            if old == new { return }
            if let event = new.first {
                switch event {
                case .onChanged:
                    guard let onChanged else { return }
                    if onChanged(viewModel.uiState.coordinates) {
                        dismiss()
                    }
                }

                viewModel.consumeEvent(event)
            }
        }
    }
}

// MARK: - Previews

#Preview {
    CoordinatesEditView(
        coordinates: .init("318, 63, 1143")
    )
}

#Preview {
    CoordinatesEditView(
        coordinates: nil
    )
}
