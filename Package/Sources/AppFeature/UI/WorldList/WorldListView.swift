import SwiftUI

@MainActor
struct WorldListView: View {
    @State private var viewModel: WorldListViewModel = .init()
    @State private var isShowEditView = false

    @Binding var navigatePath: NavigationPath
    var selectedAction: ((_ selected: World) -> Void)?

    var body: some View {
        ZStack {
            List {
                ForEach(viewModel.uiState.worlds, id: \.self) { world in
                    NavigationLink(value: world) {
                        WorldListCell(world: world)
                    }
                }
                .onDelete { offsets in
                    Task {
                        await viewModel.send(action: .onDeleteButtonClick(offsets: offsets))
                    }
                }
            }
            .listStyle(.plain)
            .task {
                await viewModel.send(action: .load)
            }
            .refreshable {
                await viewModel.send(action: .load)
            }
            .navigationDestination(for: World.self) { world in
                WorldDetailView(world: world)
            }

            FloatingButton(action: {
                isShowEditView.toggle()
            }, label: {
                ZStack {
                    Image(systemName: "globe.desk")
                        .foregroundColor(.white)
                        .font(.system(size: 24))
                        .padding(.trailing, 10)
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 15))
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: .infinity,
                            alignment: .trailing
                        )
                        .padding(2)
                }
            })
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitle(Text("WorldListView.Title", bundle: .module))
//        .navigationBarItems(trailing: EditButton())
        .toolbarBackground(.visible, for: .navigationBar)
        .sheet(isPresented: $isShowEditView, content: {
            WorldEditView(
                onTapDismiss: { _ in
                    Task {
                        await viewModel.send(action: .reload)
                    }
                }
            )
            .presentationDetents([.medium, .large])
        })
        .deleteAlert(
            message: viewModel.uiState.deleteAlertMessage,
            onDelete: {
                Task {
                    await viewModel.send(action: .onDelete)
                }
            },
            onDismiss: {
                Task {
                    await viewModel.send(action: .onDeleteAlertDismiss)
                }
            }
        )
        .analyticsScreen(name: "WorldListView", class: String(describing: type(of: self)))
    }
}

// MARK: - Privates

private extension View {
    func deleteAlert(
        message: String?,
        onDelete: @escaping () -> Void,
        onDismiss: @escaping () -> Void
    ) -> some View {
        alert(
            "Confirmation",
            isPresented: .init(
                get: { message != nil },
                set: { _ in onDismiss() }
            ),
            presenting: message
        ) { _ in
            Button("Delete", role: .destructive, action: {
                onDelete()
            })
        } message: { message in
            Text(message)
        }
    }
}

// MARK: - Previews

#Preview {
    WorldListView(navigatePath: .constant(NavigationPath()))
}
