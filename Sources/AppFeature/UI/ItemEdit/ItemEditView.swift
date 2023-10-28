//
//  Created by yoko-yan on 2023/07/03.
//

import SwiftUI

struct ItemEditView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: ItemEditViewModel
    private let onDelete: ((Item) -> Void)?
    private let onChange: ((Item) -> Void)?

    @State private var isImagePicker = false
    @State private var imageSourceType = ImagePicker.SourceType.library

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 10) {
                        SpotImageEditCell(
                            image: viewModel.uiState.spotImage,
                            isImagePicker: $isImagePicker,
                            imageSourceType: $imageSourceType
                        )

                        coordinatesEditCell

                        Divider()

                        worldEditCell

                        Color.clear
                            .frame(height: 100)
                    }
                }

                footer
                    .ignoresSafeArea(.keyboard, edges: .bottom)
            }
            .sheet(isPresented: $isImagePicker) {
                ImagePicker(
                    show: $isImagePicker,
                    image: .init(
                        get: { viewModel.uiState.spotImage },
                        set: { newValue in
                            guard let newValue else { return }
                            Task {
                                await viewModel.send(action: .setSpotImage(newValue))
                                await viewModel.send(action: .getCoordinates(from: newValue))
                            }
                        }
                    ),
                    sourceType: imageSourceType,
                    allowsEditing: true
                )
            }
            .task {
                await viewModel.send(action: .loadImage)
                await viewModel.send(action: .getWorlds)
            }
            .onChange(of: viewModel.uiState.event) { [old = viewModel.uiState.event] new in
                if old == new { return }
                if let event = new.first {
                    switch event {
                    case .onChanged:
                        onChange?(viewModel.uiState.editItem)

                    case .onDeleted:
                        onDelete?(viewModel.uiState.editItem)

                    case .onDismiss:
                        dismiss()
                    }

                    viewModel.consumeEvent(event)
                }
            }
            .navigationBarTitle(viewModel.uiState.editMode.title, displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        Task {
                            await viewModel.send(action: .onCloseButtonTap)
                        }
                    }) {
                        Image(systemName: "xmark")
                    }
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .confirmationAlert(
                alertType: viewModel.uiState.confirmationAlert,
                onConfirmed: {
                    if let action =
                        viewModel.uiState.confirmationAlert?.action
                    {
                        Task {
                            await viewModel.send(action: action)
                        }
                    }
                },
                onDismiss: {
                    Task {
                        await viewModel.send(action: .onAlertDismiss)
                    }
                }
            )
        }
        .interactiveDismissDisabled(viewModel.uiState.isChanged)
        .errorAlert(error: viewModel.uiState.error) {
            Task {
                await viewModel.send(action: .onErrorAlertDismiss)
            }
        }
    }

    init(item: Item? = nil, onDelete: ((Item) -> Void)? = nil, onChange: ((Item) -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: ItemEditViewModel(item: item))
        self.onDelete = onDelete
        self.onChange = onChange
    }
}

// MARK: - Privates

private extension ItemEditView {
    var coordinatesEditCell: some View {
        NavigationLink {
            CoordinatesEditView(
                coordinates: viewModel.uiState.input.coordinates
            ) { coordinates in
                Task {
                    await viewModel.send(action: .setCoordinates(coordinates))
                }
                return true
            }
        } label: {
            HStack {
                Label("coordinates", systemImage: "location.circle")
                Spacer()
                Text(viewModel.uiState.input.coordinates?.text ?? "未登録")
                Image(systemName: "chevron.right")
            }
            .padding(.horizontal)
            .accentColor(.gray)
        }
    }

    var worldEditCell: some View {
        HStack {
            NavigationLink {
                WorldSelectionView(
                    worlds: viewModel.uiState.worlds,
                    selected: .init(
                        get: { viewModel.uiState.input.world },
                        set: { newValue in
                            guard let newValue else { return }
                            Task {
                                await viewModel.send(action: .setWorld(newValue))
                            }
                        }
                    )
                )
            } label: {
                HStack {
                    Label("seed", systemImage: "globe.desk")
                    Spacer()
                    Text(viewModel.uiState.input.world?.seed?.text ?? "未登録")
                    Image(systemName: "chevron.right")
                }
                .padding(.horizontal)
                .accentColor(.gray)
            }
        }
    }

    var footer: some View {
        VStack {
            Spacer()
            HStack {
                if case .update = viewModel.uiState.editMode {
                    Button(action: {
                        Task {
                            await viewModel.send(action: .onDeleteButtonTap)
                        }
                    }) {
                        Text("削除する")
                            .bold()
                            .frame(height: 50)
                            .padding(.horizontal)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.red, lineWidth: 1)
                            )
                    }
                    .foregroundColor(.red)
                }

                Button(action: {
                    Task {
                        switch viewModel.uiState.editMode {
                        case .add:
                            Task {
                                await viewModel.send(action: .onRegisterButtonTap)
                            }

                        case .update:
                            Task {
                                await viewModel.send(action: .onUpdateButtonTap)
                            }
                        }
                    }
                }) {
                    Text(viewModel.uiState.editMode.button)
                        .bold()
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(RoundedButtonStyle(color: .red))
            }
        }
        .padding()
    }
}

private extension View {
    func confirmationAlert(
        alertType: ItemEditUiState.AlertType?,
        onConfirmed: @escaping () -> Void,
        onDismiss: @escaping () -> Void
    ) -> some View {
        confirmationDialog(
            "確認",
            isPresented: .init(
                get: { alertType?.message != nil },
                set: { _ in onDismiss() }
            ),
            presenting: alertType
        ) { _ in
            Button("キャンセル", role: .cancel, action: {})
            Button(
                alertType?.buttonLabel ?? "",
                role: alertType?.buttonRole,
                action: { onConfirmed() }
            )
        } message: { alertType in
            Text(alertType.message)
        }
    }
}

// MARK: - Previews

#Preview {
    ItemEditView(
        item: Item(
            id: "",
            coordinates: Coordinates(x: 100, y: 20, z: 300),
            world: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
    )
}

#Preview {
    ItemEditView()
}
