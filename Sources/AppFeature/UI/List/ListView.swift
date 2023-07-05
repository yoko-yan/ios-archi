//
//  ListView.swift
//
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
                List(viewModel.uiState.items) { item in
                    NavigationLink(value: item) {
                        ZStack(alignment: .leading) {
                            if let image = viewModel.loadImage(fileName: item.coordinatesImageName) {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(4 / 3, contentMode: .fill)
                            } else {
                                Text("画像なし")
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .foregroundColor(.gray)
                                    .aspectRatio(4 / 3, contentMode: .fill)
                            }

                            if item.coordinates != nil || item.coordinates != nil {
                                VStack {
                                    Spacer()
                                    ZStack {
                                        VStack {
                                            Spacer()
                                            Color.black
                                                .frame(width: .infinity)
                                                .frame(maxHeight: 50)
                                                .opacity(0.5)
                                        }
                                        HStack {
                                            if let coordinates = item.coordinates {
                                                HStack {
                                                    Image(systemName: "location.circle")
                                                    Text(coordinates.text)
                                                }
                                            }
                                            Spacer()
                                            if let seed = item.seed {
                                                HStack {
                                                    Image(systemName: "globe.desk")
                                                    Text(seed.text)
                                                }
                                            }
                                        }
                                        .foregroundColor(.white)
                                        .padding()
                                    }
                                    .frame(maxHeight: 40)
                                }
                            }
                        }
                        .modifier(CardStyle())
                        .aspectRatio(4 / 3, contentMode: .fill)
                    }
                    .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarTitle(Text("スポット一覧"))
                .task {
                    viewModel.loadItems()
                }
                .refreshable {
                    viewModel.loadItems()
                }
                .navigationDestination(for: Item.self) { item in
                    DetailView(item: item)
                }

                FloatingButton(action: {
                    isShowDetailView.toggle()
                }, label: {
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                        .font(.system(size: 24))
                })
            }
            .fullScreenCover(isPresented: $isShowDetailView) {
                EditItemView()
            }
        }
    }

    init() {
        self.init(viewModel: ListViewModel())

//        // FIXME: DEBUG
//        ItemRepository().create(
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
