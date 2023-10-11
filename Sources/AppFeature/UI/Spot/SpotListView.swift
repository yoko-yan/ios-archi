//
//  Created by apla on 2023/10/08
//

import SwiftUI

struct SpotListView: View {
    @StateObject private var viewModel = SpotListViewModel()

    private let columns = [
        GridItem(.adaptive(minimum: 80))
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(viewModel.uiState.items, id: \.self) { item in
                    NavigationLink(value: item) {
                        let image = viewModel.loadImage(fileName: item.spotImageName)
                        SpotListCell(item: item, image: image)
                            .padding(.bottom, 4)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top)
            .navigationDestination(for: Item.self) { item in
                DetailView(item: item)
            }
        }
        .task {
            viewModel.send(.load)
        }
        .refreshable {
            viewModel.send(.load)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitle(Text("スポット一覧"))
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

#Preview {
    SpotListView()
}
