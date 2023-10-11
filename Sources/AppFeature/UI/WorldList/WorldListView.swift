//
//  Created by takayuki.yokoda on 2023/07/01.
//

import SwiftUI

struct WorldListView: View {
    @StateObject private var viewModel: WorldListViewModel = .init()
    @State private var isShowDetailView = false

    @Binding var navigatePath: NavigationPath
    var selectedAction: ((_ selected: Seed) -> Void)?

    var body: some View {
        ZStack {
            List {
                ForEach(viewModel.uiState.items, id: \.self) { seed in
                    WorldListCell(seed: seed)
                        .onTapGesture {
                            if let selectedAction {
                                selectedAction(seed)
                            }
                            navigatePath.append(seed)
                        }
                }
            }
            .listStyle(.plain)
            .task {
                viewModel.send(.load)
            }
            .refreshable {
                viewModel.send(.load)
            }
            .navigationDestination(for: Seed.self) { _ in
                WorldDetailView(navigatePath: $navigatePath)
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

// #Preview {
//    WorldListView(navigatePath: .constant([]))
// }
