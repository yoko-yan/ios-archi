//
//  Created by takayuki.yokoda on 2023/07/01.
//

import SwiftUI

struct ListView: View {
    @StateObject private var viewModel: ListViewModel
    @State private var isShowDetailView = false

    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    ForEach(viewModel.uiState.seeds, id: \.self) { seed in
                        NavigationLink(value: seed) {
                            ListCell(seed: seed)
                                .padding(.top)
                        }
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
                .navigationDestination(for: Item.self) { item in
                    DetailView(item: item)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitle(Text("ワールド一覧"))
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    init() {
        self.init(viewModel: ListViewModel())
    }

    private init(viewModel: ListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
}

#Preview {
    ListView()
}
