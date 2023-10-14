//
//  Created by apla on 2023/10/08
//

import SwiftUI

struct SpotListView: View {
    @StateObject private var viewModel: SpotListViewModel

    private let columns = [
        GridItem(.adaptive(minimum: 80))
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(viewModel.uiState.items, id: \.self) { item in
                    NavigationLink(value: item) {
                        let image = viewModel.loadImage(fileName: item.spotImageName)
                        SpotListCell(item: item, image: image)
                    }
                }
            }
            .padding(8)
            .navigationDestination(for: Item.self) { item in
                ItemDetailView(item: item)
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

    init() {
        self.init(viewModel: SpotListViewModel())
    }

    init(viewModel: SpotListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
}

#Preview {
    SpotListView(
        viewModel: SpotListViewModel(
            uiState: SpotListUiState(
                items: [
                    Item(
                        id: "",
                        coordinates: Coordinates(x: 100, y: 20, z: 300),
                        world: nil,
                        createdAt: Date(),
                        updatedAt: Date()
                    ),
                    Item(
                        id: "",
                        coordinates: Coordinates(x: 100, y: 20, z: 300),
                        world: nil,
                        createdAt: Date(),
                        updatedAt: Date()
                    )
                ]
            )
        )
    )
}
