//
//  Created by takayuki.yokoda on 2023/07/01.
//

import SwiftUI

struct WorldListView: View {
    @StateObject private var viewModel: WorldListViewModel = .init()
    @State private var isShowDetailView = false

    @Binding var navigatePath: NavigationPath
    var selectedAction: ((_ selected: Seed) -> Void)? = nil

    var body: some View {
        ZStack {
            List {
                ForEach(viewModel.uiState.seeds, id: \.self) { seed in
//                    NavigationLink(value: seed) {
                    WorldListCell(seed: seed)
                        .padding(.top)
                        .onTapGesture {
                            if let selectedAction {
                                selectedAction(seed)
                            }
                            navigatePath.append(seed)
//                            navigatePath.removeLast()
                        }
//                    }
                }
                .listRowSeparator(.hidden)
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
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitle(Text("ワールド一覧"))
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

// #Preview {
//    WorldListView(navigatePath: .constant([]))
// }
