//
//  Created by takayuki.yokoda on 2023/07/01.
//

import SwiftUI

struct WorldListView: View {
    @StateObject private var viewModel: WorldListViewModel = .init()
    @State private var isShowDetailView = false

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
                .onDelete { viewModel.send(.onDeleteButtonClick(offsets: $0)) }
            }
            .listStyle(.plain)
            .task {
                viewModel.send(.load)
            }
            .refreshable {
                viewModel.send(.load)
            }
            .navigationDestination(for: World.self) { world in
                WorldDetailView(world: world)
            }

            FloatingButton(action: {
                isShowDetailView.toggle()
            }, label: {
                Image(systemName: "plus")
                    .foregroundColor(.white)
                    .font(.system(size: 24))
            })
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitle(Text("ワールド一覧"))
//        .navigationBarItems(trailing: EditButton())
        .toolbarBackground(.visible, for: .navigationBar)
        .sheet(isPresented: $isShowDetailView) {
            WorldEditItemView(
                onTapDismiss: { _ in
                    viewModel.send(.reload)
                }
            )
        }
        .deleteAlert(
            message: viewModel.uiState.deleteAlertMessage,
            onDelete: { viewModel.send(.onDelete) },
            onDismiss: { viewModel.send(.onDeleteAlertDismiss) }
        )
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
            "確認",
            isPresented: .init(
                get: { message != nil },
                set: { _ in onDismiss() }
            ),
            presenting: message
        ) { _ in
            Button("削除する", role: .destructive, action: {
                onDelete()
            })
        } message: { message in
            Text(message)
        }
    }
}

#Preview {
    WorldListView(navigatePath: .constant(NavigationPath()))
}
