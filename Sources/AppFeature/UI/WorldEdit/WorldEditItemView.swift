//
//  Created by yoko-yan on 2023/10/08
//

import SwiftUI

struct WorldEditItemView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: WorldEditItemViewModel
    private let onTapDelete: ((World) -> Void)?
    private let onTapDismiss: ((World) -> Void)?

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
        .interactiveDismissDisabled(viewModel.uiState.isChanged)
    }

    init(world: World? = nil, onTapDelete: ((World) -> Void)? = nil, onTapDismiss: ((World) -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: WorldEditItemViewModel(world: world))
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
            isPresented: .init(
                get: { alertType?.message != nil },
                set: { _ in onDismiss() }
            ),
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

// MARK: - Previews

#Preview {
    WorldEditItemView(
        world: World(
            id: "",
            name: "自分の世界",
            seed: Seed("111111"),
            createdAt: Date(),
            updatedAt: Date()
        )
    )
}

#Preview {
    WorldEditItemView()
}
