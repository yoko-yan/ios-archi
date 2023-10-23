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
                                    await viewModel.send(action: .onRegisterButtonTap)

                                case .update:
                                    await viewModel.send(action: .onUpdateButtonTap)
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
            .onChange(of: viewModel.uiState.seedImage) { [old = viewModel.uiState.seedImage] new in
                if old == new { return }
                if let new {
                    Task {
                        await viewModel.send(action: .getSeed(image: new))
                    }
                }
            }
            .onChange(of: viewModel.uiState.event) { [old = viewModel.uiState.event] new in
                if old == new { return }
                if let event = new.first {
                    switch event {
                    case .onChanged:
                        onTapDismiss?(viewModel.uiState.editItem)
                        dismiss()

                    case .onDeleted:
                        onTapDelete?(viewModel.uiState.editItem)
                        dismiss()

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
                    Task {
                        if let action = viewModel.uiState.confirmationAlert?.action {
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
