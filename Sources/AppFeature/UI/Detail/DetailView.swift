//
//  Created by takayuki.yokoda on 2023/07/01.
//

import SwiftUI

struct DetailView: View {
    @StateObject private var viewModel: DetailViewModel
    @State private var isEditView = false
    @State private var isBiomeFinderView = false

    var body: some View {
        ZStack {
            ScrollView {
                CoordinatesView(
                    coordinates: viewModel.uiState.item.coordinates,
                    image: viewModel.uiState.coordinatesImage
                )

                Divider()

                SeedView(
                    seed: viewModel.uiState.item.seed,
                    image: viewModel.uiState.seedImage
                )

                Divider()

                Button {
                    isBiomeFinderView.toggle()
                } label: {
                    Text("座標とシード値からバイオームを検索")
                        .bold()
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(OutlineButtonStyle(color: .black))
                .padding()

                Button(action: {
                    isEditView.toggle()
                }) {
                    Text("編集する")
                        .bold()
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(OutlineButtonStyle(color: .green))
                .padding()
            }
        }
        .navigationBarTitle("詳細", displayMode: .inline)
//        .toolbar {
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Button(action: {
//                    isEditView.toggle()
//                }) {
//                    HStack {
//                        Text("編集")
//                    }
//                }
//            }
//        }
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.light, for: .navigationBar)
        .task {
            viewModel.loadImage()
        }
        .sheet(isPresented: $isBiomeFinderView) {
            BiomeFinderView(
                seed: viewModel.uiState.item.seed?.rawValue ?? 0,
                coordinates: viewModel.uiState.item.coordinates ?? Coordinates(x: 0, y: 0, z: 0)
            )
        }
        .fullScreenCover(isPresented: $isEditView) {
            EditItemView(item: viewModel.uiState.item) { item in
                viewModel.reload(item: item)
            }
        }
    }

    init(item: Item) {
        _viewModel = StateObject(wrappedValue: DetailViewModel(item: item))
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(
            item: Item(
                id: UUID().uuidString,
                coordinates: .zero,
                seed: .zero,
                createdAt: Date(),
                updatedAt: Date()
            )
        )
        DetailView(
            item: Item(
                id: UUID().uuidString,
                coordinates: nil,
                seed: nil,
                createdAt: Date(),
                updatedAt: Date()
            )
        )
        DetailView(
            item: Item(
                id: UUID().uuidString,
                coordinates: Coordinates(x: 100, y: 20, z: 300),
                seed: Seed(rawValue: 500),
                createdAt: Date(),
                updatedAt: Date()
            )
        )
    }
}
