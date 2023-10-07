//
//  Created by apla on 2023/10/08
//

import SwiftUI

struct WorldEditItemView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: WorldEditItemViewModel
    private let onTapDelete: ((Item) -> Void)?
    private let onTapDismiss: ((Item) -> Void)?

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 10) {
                        SeedEditView(
                            seed: viewModel.input.seed,
                            image: viewModel.seedImage
                        )

                        Divider()

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
                Task {
                    await viewModel.send(.loadImage)
                    await viewModel.send(.getWorlds)
                }
            }
            .onChange(of: viewModel.uiState) { [oldState = viewModel.uiState] newState in
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
    }

    init(item: Item? = nil, onTapDelete: ((Item) -> Void)? = nil, onTapDismiss: ((Item) -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: WorldEditItemViewModel(item: item))
        self.onTapDelete = onTapDelete
        self.onTapDismiss = onTapDismiss
    }
}

private extension View {
    func confirmationAlert(
        alertType: WorldEditItemUiState.AlertType?,
        onConfirmed: @escaping () -> Void,
        onDismiss: @escaping () -> Void
    ) -> some View {
        confirmationDialog(
            "確認",
            isPresented: .init(get: {
                alertType?.message != nil
            }, set: { _ in
                onDismiss()
            }),
            presenting: alertType
        ) { _ in
            Button("キャンセル", role: .cancel, action: {})
            Button(alertType?.buttonLabel ?? "", role: alertType?.buttonRole, action: {
                onConfirmed()
            })
        } message: { alertType in
            Text(alertType.message)
        }
    }
}

#Preview {
    WorldEditItemView(
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
    WorldEditItemView()
}