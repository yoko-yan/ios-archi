//
//  Created by takayuki.yokoda on 2023/07/03.
//

import SwiftUI

struct ItemEditView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: ItemEditViewModel
    private let onTapDelete: ((Item) -> Void)?
    private let onTapDismiss: ((Item) -> Void)?

    var body: some View {
        // FIXME:
        NavigationStack { // swiftlint:disable:this closure_body_length
            ZStack {
                ScrollView {
                    VStack(spacing: 10) {
                        SpotImageView(
                            image: viewModel.spotImage
                        )

                        CoordinatesEditView(
                            coordinates: viewModel.input.coordinates
                        )

                        Divider()

                        HStack {
                            NavigationLink {
                                WorldSelectionView(
                                    worlds: viewModel.uiState.worlds,
                                    selected: viewModel.uiState.editMode.item?.world
                                ) { world in
                                    Task {
                                        await viewModel.send(.set(world: world))
                                    }
                                }
                            } label: {
                                HStack {
                                    Label("seed", systemImage: "globe.desk")
                                    Spacer()
                                    Text(viewModel.uiState.editItem.world?.seed?.text ?? "未登録")
                                    Image(systemName: "chevron.right")
                                }
                                .padding(.horizontal)
                                .accentColor(.gray)
                            }
                        }

                        Color.clear
                            .frame(height: 100)
                    }
                }

                VStack {
                    Spacer()
                    HStack {
                        if case .update = viewModel.uiState.editMode {
                            Button(action: {
                                Task {
                                    await viewModel.send(.onDeleteButtonClick)
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
                                    await viewModel.send(.onRegisterButtonClick)

                                case .update:
                                    await viewModel.send(.onUpdateButtonClick)
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
                .ignoresSafeArea(.keyboard, edges: .bottom)
            }
            .task {
                Task {
                    await viewModel.send(.loadImage)
                    await viewModel.send(.getWorlds)
                }
            }
            .onChange(of: viewModel.uiState) { [oldState = viewModel.uiState] newState in
                if let spotImage = newState.spotImage, oldState.spotImage != spotImage {
                    Task {
                        await viewModel.send(.getCoordinates(image: spotImage))
                    }
                }

                if let event = newState.event {
                    switch event {
                    case .updated:
                        onTapDismiss?(viewModel.uiState.editItem)
                        dismiss()

                    case .deleted:
                        onTapDelete?(viewModel.uiState.editItem)
                        dismiss()

                    case .dismiss:
                        dismiss()
                    }

                    viewModel.consumeEvent()
                }
            }
            .navigationBarTitle(viewModel.uiState.editMode.title, displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        Task {
                            await viewModel.send(.onCloseButtonTap)
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
                    Task {
                        if let action = viewModel.uiState.confirmationAlert?.action {
                            await viewModel.send(action)
                        }
                    }
                },
                onDismiss: {
                    Task {
                        await viewModel.send(.onAlertDismiss)
                    }
                }
            )
        }
        .interactiveDismissDisabled(viewModel.uiState.isChanged)
    }

    init(item: Item? = nil, onTapDelete: ((Item) -> Void)? = nil, onTapDismiss: ((Item) -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: ItemEditViewModel(item: item))
        self.onTapDelete = onTapDelete
        self.onTapDismiss = onTapDismiss
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
