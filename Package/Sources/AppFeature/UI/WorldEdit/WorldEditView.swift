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
                        nameEditCell

                        Divider()

                        seedEditCell

                        Color.clear
                            .frame(height: 100)
                    }
                }

                footer
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
            .toolbar {
                keyboardToolbarItem
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

// MARK: - Privates

private extension WorldEditView {
    var nameEditCell: some View {
        VStack {
            HStack {
                Text("Title", bundle: .module)
                Spacer()
            }
            TextField(
                String(localized: "Unregistered", bundle: .module),
                text: .init(
                    get: { viewModel.uiState.input.name ?? "" },
                    set: { newValue in
                        Task {
                            await viewModel.send(action: .setName(newValue))
                        }
                    }
                )
            )
            .multilineTextAlignment(TextAlignment.leading)
            .modifier(
                TextFieldClearButton(
                    text: .init(
                        get: { viewModel.uiState.input.name ?? "" },
                        set: { newValue in
                            Task {
                                await viewModel.send(action: .setName(newValue))
                            }
                        }
                    )
                )
            )
            .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding()
    }

    var seedEditCell: some View {
        NavigationLink {
            SeedEditView(
                seed: viewModel.uiState.input.seed
            ) { seed in
                Task {
                    await viewModel.send(action: .setSeed(seed))
                }
                return true
            }
        } label: {
            HStack {
                Text("Seed", bundle: .module)
                Spacer()
                Text(viewModel.uiState.input.seed?.text ?? String(localized: "Unregistered", bundle: .module))
                Image(systemName: "chevron.right")
            }
            .padding(.horizontal)
            .accentColor(.gray)
        }
    }

    var footer: some View {
        VStack {
            Spacer()
            HStack {
                if case .edit = viewModel.uiState.editMode {
                    Button(action: {
                        Task {
                            await viewModel.send(action: .onDeleteButtonTap)
                        }
                    }) {
                        Text("Delete", bundle: .module)
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

private extension View {
    func confirmationAlert(
        alertType: WorldEditUiState.AlertType?,
        onConfirmed: @escaping () -> Void,
        onDismiss: @escaping () -> Void
    ) -> some View {
        confirmationDialog(
            "Confirmation",
            isPresented: .init(
                get: { alertType?.message != nil },
                set: { _ in onDismiss() }
            ),
            presenting: alertType
        ) { _ in
            Button("Cancel", role: .cancel, action: {})
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
