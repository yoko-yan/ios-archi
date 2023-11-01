//
//  Created by yoko-yan on 2023/10/08
//

import Core
import SwiftUI

struct SpotListView: View {
    @StateObject private var viewModel: SpotListViewModel
    @State private var isShowEditView = false

    private let columns = [
        GridItem(.adaptive(minimum: 80))
    ]

    var body: some View {
        ZStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(viewModel.uiState.items, id: \.self) { item in
                        NavigationLink(value: item) {
                            SpotListCell(
                                item: item,
                                spotImage: viewModel.uiState.spotImages[item.id] as? SpotImage
                            ) { item in
                                viewModel.loadImage(item: item)
                            }
                        }
                    }
                }
                .padding(8)
                .navigationDestination(for: Item.self) { item in
                    ItemDetailView(item: item)
                }
            }

            FloatingButton(action: {
                isShowEditView.toggle()
            }, label: {
                Image(systemName: "plus")
                    .foregroundColor(.white)
                    .font(.system(size: 24))
            })
        }
        .task {
            await viewModel.send(action: .load)
        }
        .refreshable {
            await viewModel.send(action: .load)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitle(Text("写真一覧"))
        .toolbarBackground(.visible, for: .navigationBar)
        .sheet(isPresented: $isShowEditView) {
            ItemEditView(
                onChange: { _ in
                    Task {
                        await viewModel.send(action: .reload)
                    }
                }
            )
        }
        .analyticsScreen(name: "SpotListView", class: String(describing: type(of: self)))
    }

    init() {
        self.init(viewModel: SpotListViewModel())
    }

    init(viewModel: SpotListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
}

// MARK: - Previews

// #Preview {
//    SpotListView(
//        viewModel: SpotListViewModel(
//            uiState: SpotListUiState(
//                items: [
//                    Item(
//                        id: "",
//                        coordinates: Coordinates(x: 100, y: 20, z: 300),
//                        world: nil,
//                        createdAt: Date(),
//                        updatedAt: Date()
//                    ),
//                    Item(
//                        id: "",
//                        coordinates: Coordinates(x: 100, y: 20, z: 300),
//                        world: nil,
//                        createdAt: Date(),
//                        updatedAt: Date()
//                    )
//                ]
//            )
//        )
//    )
// }
