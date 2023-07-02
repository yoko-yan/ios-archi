//
//  ListView.swift
//
//
//  Created by takayuki.yokoda on 2023/07/01.
//

import SwiftUI

struct ListView: View {
    @StateObject private var viewModel: ListViewModel
    @State private var path: [Item] = []

    var body: some View {
        NavigationStack(path: $path) {
            List(viewModel.uiState.items) { item in
                NavigationLink(value: item) {
                    HStack {
                        VStack(alignment: .leading) {
                            if let image = viewModel.loadImage(itemsId: item.id) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                Image(systemName: "sample-coordinates")
                                    .resizable()
                                    .scaledToFill()
                            }
                            VStack(alignment: .leading) {
                                if let seed = item.seed {
                                    HStack {
                                        Image(systemName: "globe")
                                        Text(seed.text)
                                    }
                                }
                                if let coordinates = item.coordinates {
                                    HStack {
                                        Image(systemName: "location.circle")
                                            .accentColor(.gray)
                                        Text(coordinates.text)
                                    }
                                }
                            }
                            .foregroundColor(.gray)
                            .padding()
                        }
                    }
                    .modifier(CardStyle())
                }
            }
            .listStyle(.plain)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitle(Text("a"))
            .task {
                viewModel.loadItems()
            }
            .refreshable {
                viewModel.loadItems()
            }
            .navigationDestination(for: Item.self) { item in
                UpdateItemView(item: item)
            }
        }
    }

    init() {
        self.init(viewModel: ListViewModel())

//        // FIXME: DEBUG
//        ItemsRepository().create(
//            items:
//            [
//                Item(seed: .zero, coordinates: .zero),
//                Item(seed: nil, coordinates: nil),
//                Item(
//                    seed: Seed(rawValue: 500),
//                    coordinates: Coordinates(x: 100, y: 20, z: 300)
//                )
//            ]
//        )
    }

    private init(viewModel: ListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
    }
}
