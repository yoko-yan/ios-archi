//
//  Created by yoko-yan on 2023/11/03
//

import Core
import SwiftUI

struct SeedEditView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: SeedEditViewModel

    @State private var isImagePicker = false
    @State private var imageSourceType = ImagePicker.SourceType.library

    private let onChanged: ((Seed?) -> Bool)?

    var body: some View {
        seedEditCell
            .sheet(isPresented: $isImagePicker) {
                ImagePicker(
                    show: $isImagePicker,
                    image: .init(
                        get: { viewModel.uiState.seedImage },
                        set: { newValue in
                            guard let newValue else { return }
                            Task {
                                await viewModel.send(action: .setSeedImage(newValue))
                                await viewModel.send(action: .getSeed(from: newValue))
                            }
                        }
                    ),
                    sourceType: imageSourceType,
                    allowsEditing: true
                )
            }
            .analyticsScreen(name: "SeedEditView", class: String(describing: type(of: self)))
    }

    init(seed: Seed?, onChanged: ((Seed?) -> Bool)? = nil) {
        _viewModel = StateObject(
            wrappedValue: SeedEditViewModel(seed: seed)
        )
        self.onChanged = onChanged
    }
}

// MARK: - Privates

private extension SeedEditView {
    var seedEditCell: some View {
        ZStack {
            ScrollView {
                VStack {
                    if let image = viewModel.uiState.seedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                    } else {
                        Button {
                            imageSourceType = .library
                            isImagePicker.toggle()
                        } label: {
                            Text("Recognize the seed value string from a photo", bundle: .module)
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
                        Text("If the seed value is visible in the photo, it can be recognized", bundle: .module)
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
                        Text("Seed", bundle: .module)
                        Spacer()
                    }
                    .padding(.horizontal)

                    HStack {
                        TextField(
                            "Seed",
                            text: .init(
                                get: { viewModel.uiState.seedText },
                                set: { newValue in
                                    Task {
                                        await viewModel.send(action: .setSeed(newValue))
                                    }
                                }
                            )
                        )
                        .keyboardType(.numbersAndPunctuation)
                        .multilineTextAlignment(TextAlignment.leading)
                        .modifier(
                            TextFieldClearButton(
                                text: .init(
                                    get: { viewModel.uiState.seedText },
                                    set: { newValue in
                                        Task {
                                            await viewModel.send(action: .setSeed(newValue))
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
                    if viewModel.uiState.seed != nil {
                        Button(action: {
                            Task {
                                await viewModel.send(action: .clearSeed)
                            }
                        }) {
                            Text("Clear", bundle: .module)
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
                        Text("Modify", bundle: .module)
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
        .navigationBarTitle("Change the seed", displayMode: .inline)
        .toolbar {
            keyboardToolbarItem
        }
        .onChange(of: viewModel.uiState.events) { [old = viewModel.uiState.events] new in
            if old == new { return }
            if let event = new.first {
                switch event {
                case .onChanged:
                    guard let onChanged else { return }
                    if onChanged(viewModel.uiState.seed) {
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
    SeedEditView(
        seed: .init("318631143")
    )
}

#Preview {
    SeedEditView(
        seed: nil
    )
}
