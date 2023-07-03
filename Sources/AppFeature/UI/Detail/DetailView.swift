//
//  DetailView.swift
//
//
//  Created by takayuki.yokoda on 2023/07/01.
//

import SwiftUI

struct DetailView: View {
    @StateObject private var viewModel: DetailViewModel
    @State private var isEditView = false
    @State private var isBiomeFinderView = false

    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 10) {
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
                        Text("シード値と座標からバイオームを検索")
                    }
                    .accentColor(.gray)
                    .buttonStyle(OutlineButtonStyle())
                }
            }
        }
        .navigationBarTitle("詳細", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    isEditView.toggle()
                }) {
                    HStack {
                        Text("編集")
                    }
                }
            }
        }
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
            EditItemView(item: viewModel.uiState.item)
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
                seed: .zero
            )
        )
        DetailView(
            item: Item(
                id: UUID().uuidString,
                coordinates: nil,
                seed: nil
            )
        )
        DetailView(
            item: Item(
                id: UUID().uuidString,
                coordinates: Coordinates(x: 100, y: 20, z: 300),
                seed: Seed(rawValue: 500)
            )
        )
    }
}
