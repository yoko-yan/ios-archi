import SwiftUI

@MainActor
struct CoordinatesEditView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) var dismiss
    @State private var viewModel: CoordinatesEditViewModel

    @State private var isImagePicker = false
    @State private var imageSourceType = ImagePicker.SourceType.library

    private let onChanged: ((Coordinates?) -> Bool)?

    var body: some View {
        coordinatesEditCell
            .sheet(isPresented: $isImagePicker, content: {
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
            })
            .analyticsScreen(name: "CoordinatesEditView", class: String(describing: type(of: self)))
    }

    init(coordinates: Coordinates?, onChanged: ((Coordinates?) -> Bool)? = nil) {
        _viewModel = State(
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
                            Text("Recognize coordinate strings from a photo", bundle: .module)
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

                    HStack {
                        Label(String(localized: "Coordinates", bundle: .module), systemImage: "location.circle")
                        Spacer()
                    }
                    .padding(.horizontal)

                    HStack {
                        TextField(
                            "X",
                            text: .init(
                                get: { viewModel.uiState.coordinatesXText },
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
                                    get: { viewModel.uiState.coordinatesXText },
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
                                get: { viewModel.uiState.coordinatesYText },
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
                                    get: { viewModel.uiState.coordinatesYText },
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
                                get: { viewModel.uiState.coordinatesZText },
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
                                    get: { viewModel.uiState.coordinatesZText },
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
                        Spacer()
                        VStack {
                            ForEach(viewModel.uiState.validationErrors, id: \.self) { validationError in
                                Text(validationError.localizedDescription)
                                    .font(.caption2)
                                    .bold()
                                    .foregroundColor(.red)
                            }
                        }
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
                            Text("Clear")
                                .bold()
                                .frame(height: 40)
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
                        Label(String(localized: "Modify", bundle: .module), systemImage: "location.circle")
                            .bold()
                            .frame(height: 40)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(RoundedButtonStyle(color: .black))
                    .disabled(!viewModel.uiState.valid)
                }
                .padding()
            }
        }
        .navigationBarTitle(Text("CoordinatesEditView.Title", bundle: .module), displayMode: .inline)
        .toolbar {
            keyboardToolbarItem
        }
        .onChange(of: viewModel.uiState.events) { old, new in
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

    var keyboardToolbarItem: ToolbarItem<Void, HStack<TupleView<(Spacer, Button<Text>)>>> {
        ToolbarItem(placement: .keyboard) {
            HStack {
                Spacer()

                Button {
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder),
                        to: nil,
                        from: nil,
                        for: nil
                    )
                } label: {
                    Text(Image(systemName: "keyboard.chevron.compact.down"))
                        .font(.system(size: 15))
                }
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
