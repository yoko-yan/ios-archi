//
//  DetailView.swift
//
//
//  Created by takayuki.yokoda on 2023/07/01.
//

import SwiftUI

struct DetailView: View {
    @StateObject private var viewModel: DetailViewModel
    @State private var isBiomeFinderView = false

    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 10) {
                    SeedView(
                        seed: viewModel.item.seed,
                        image: viewModel.seedImage
                    )

                    Divider()

                    CoordinatesView(
                        coordinates: viewModel.item.coordinates,
                        image: viewModel.coordinatesImage
                    )

                    Divider()

                    Button {
                        isBiomeFinderView.toggle()
                    } label: {
                        Text("画像と座標からバイオームを検索")
                    }
                    .accentColor(.gray)
                    .buttonStyle(OutlineButtonStyle())
                }
            }
        }
        .task {
            viewModel.loadImage()
        }
        .onChange(of: viewModel.uiState) { [oldState = viewModel.uiState] newState in
            if let seedImage = newState.seedImage, oldState.seedImage != seedImage {
                viewModel.getSeed(image: seedImage)
            }
            if let coordinatesImage = newState.coordinatesImage, oldState.coordinatesImage != coordinatesImage
            {
                viewModel.getCoordinates(image: coordinatesImage)
            }
        }
        .sheet(isPresented: $isBiomeFinderView) {
            BiomeFinderView(
                seed: viewModel.uiState.item.seed?.rawValue ?? 0,
                coordinates: viewModel.uiState.item.coordinates ?? Coordinates(x: 0, y: 0, z: 0)
            )
        }
    }

    init(item: Item) {
        _viewModel = StateObject(wrappedValue: DetailViewModel(item: item))
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(item: Item(seed: .zero, coordinates: .zero))
        DetailView(item: Item(seed: nil, coordinates: nil))
        DetailView(
            item:
            Item(
                seed: Seed(rawValue: 500),
                coordinates: Coordinates(x: 100, y: 20, z: 300)
            )
        )
    }
}
