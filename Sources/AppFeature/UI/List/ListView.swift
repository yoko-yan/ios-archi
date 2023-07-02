//
//  ListView.swift
//
//
//  Created by takayuki.yokoda on 2023/07/01.
//

import SwiftUI

struct ListView: View {
    @StateObject private var viewModel: ListViewModel

    var body: some View {
        NavigationView {
            List(viewModel.uiState.items) { item in
                NavigationLink(destination: DetailView(item: item)) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("seed: \(item.seed?.text ?? "")")
                            Text("coordinates: \(item.coordinates?.text ?? "")")
                        }
                    }
                }
            }
            .listStyle(.plain)
            .task {
                viewModel.loadItems()
            }
            .refreshable {
                viewModel.loadItems()
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
