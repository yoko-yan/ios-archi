//
//  Created by takayuki.yokoda on 2023/07/03.
//

import SwiftUI

struct EditItemView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: EditItemViewModel
    private let onTapDelete: ((Item) -> Void)?
    private let onTapDismiss: ((Item) -> Void)?

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 10) {
                        CoordinatesEditView(
                            coordinates: viewModel.input.coordinates,
                            image: viewModel.coordinatesImage
                        )

                        Divider()

                        SeedEditView(
                            seed: viewModel.input.seed,
                            image: viewModel.seedImage
                        )

                        Color.clear
                            .frame(height: 100)
                    }
                    .padding(.top)
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
                            }
                            .foregroundColor(.red)
                            .padding(.horizontal)
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
            }
            .task {
                await viewModel.send(.loadImage)
            }
            .onChange(of: viewModel.uiState) { [oldState = viewModel.uiState] newState in
                if let coordinatesImage = newState.coordinatesImage, oldState.coordinatesImage != coordinatesImage
                {
                    Task {
                        await viewModel.send(.getCoordinates(image: coordinatesImage))
                    }
                }
                if let seedImage = newState.seedImage, oldState.seedImage != seedImage {
                    Task {
                        await viewModel.send(.getSeed(image: seedImage))
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
                    }

                    viewModel.consumeEvent()
                }
            }
            .navigationBarTitle(viewModel.uiState.editMode.title, displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                    }
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .confirmAlert(
                alertType: viewModel.uiState.alertType,
                onSave: {
                    Task {
                        await viewModel.send(.onUpdate)
                    }
                },
                onDismiss: {
                    Task {
                        await viewModel.send(.onAlertDismiss)
                    }
                }
            )
            .deleteAlert(
                alertType: viewModel.uiState.alertType,
                onDelete: {
                    Task {
                        await viewModel.send(.onDelete)
                    }
                },
                onDismiss: {
                    Task {
                        await viewModel.send(.onAlertDismiss)
                    }
                }
            )
        }
    }

    init(item: Item? = nil, onTapDelete: ((Item) -> Void)? = nil, onTapDismiss: ((Item) -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: EditItemViewModel(item: item))
        self.onTapDelete = onTapDelete
        self.onTapDismiss = onTapDismiss
    }
}

// MARK: - Privates

private extension View {
    func confirmAlert(
        alertType: EditItemUiState.AlertType?,
        onSave: @escaping () -> Void,
        onDismiss: @escaping () -> Void
    ) -> some View {
        alert(
            "確認",
            isPresented: .init(get: {
                alertType?.message != nil && alertType == .confirmUpdate
            }, set: { _ in
                onDismiss()
            }),
            presenting: alertType?.message
        ) { _ in
            Button("キャンセル", role: .cancel, action: {})
            Button("更新する", action: {
                onSave()
            })
        } message: { message in
            Text(message)
        }
    }

    func deleteAlert(
        alertType: EditItemUiState.AlertType?,
        onDelete: @escaping () -> Void,
        onDismiss: @escaping () -> Void
    ) -> some View {
        alert(
            "確認",
            isPresented: .init(get: {
                alertType?.message != nil && alertType == .confirmDeletion
            }, set: { _ in
                onDismiss()
            }),
            presenting: alertType?.message
        ) { _ in
            Button("キャンセル", role: .cancel, action: {})
            Button("削除する", role: .destructive, action: {
                onDelete()
            })
        } message: { message in
            Text(message)
        }
    }
}

#Preview {
    EditItemView(
        item:
        Item(
            id: "",
            coordinates: Coordinates(x: 100, y: 20, z: 300),
            seed: Seed(rawValue: 500),
            createdAt: Date(),
            updatedAt: Date()
        )
    )
}

#Preview {
    EditItemView()
}
