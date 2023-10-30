//
//  Created by yoko-yan on 2023/10/08
//

import Core
import SwiftUI

struct WorldEditView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: WorldEditViewModel
    private let onTapDelete: ((World) -> Void)?
    private let onTapDismiss: ((World) -> Void)?

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 10) {
                        SeedEditView(
                            seed: .init(
                                get: { viewModel.uiState.input.seed?.text },
                                set: { newValue in
                                    guard let newValue else { return }
                                    Task {
                                        await viewModel.send(action: .setSeed(newValue))
                                    }
                                }
                            ),
                            image: viewModel.seedImage
                        )

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

                        Color.clear
                            .frame(height: 100)
                    }
                }

                VStack {
                    Spacer()
                    HStack {
                        if case .edit = viewModel.uiState.editMode {
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
                                case .new:
                                    await viewModel.send(action: .onRegisterButtonTap)

                                case .edit:
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
                        .disabled(!viewModel.uiState.valid)
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
            .onChange(of: viewModel.uiState.events) { [old = viewModel.uiState.events] new in
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
        .errorAlert(error: viewModel.uiState.error) {
            Task {
                await viewModel.send(action: .onErrorAlertDismiss)
            }
        }
        .analyticsScreen(name: "WorldEditView", class: String(describing: type(of: self)))
    }

    init(world: World? = nil, onTapDelete: ((World) -> Void)? = nil, onTapDismiss: ((World) -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: WorldEditViewModel(world: world))
        self.onTapDelete = onTapDelete
        self.onTapDismiss = onTapDismiss
    }
}

private extension View {
    func confirmationAlert(
        alertType: WorldEditUiState.AlertType?,
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

#if DEBUG
    #Preview {
        WorldEditView(
            world: World(
                id: "",
                name: "自分の世界",
                seed: .preview,
                createdAt: Date(),
                updatedAt: Date()
            )
        )
    }

    #Preview {
        WorldEditView()
    }
#endif
