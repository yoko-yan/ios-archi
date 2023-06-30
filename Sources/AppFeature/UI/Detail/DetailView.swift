//
//  DetailView.swift
//  
//
//  Created by takayuki.yokoda on 2023/07/01.
//

import SwiftUI

struct DetailView: View {
    @StateObject private var viewModel: DetailViewModel

    @State private var seedImage: UIImage?
    @State private var coordinatesImage: UIImage?
    @State private var isBiomeFinderView = false

    var body: some View {
        // swiftlint:disable:next closure_body_length
            // swiftlint:disable:next closure_body_length
            ScrollView {
                ZStack {
                    NavigationLink(
                        destination:
                            BiomeFinderView(
                                seed: viewModel.uiState.item.seed?.rawValue ?? 0,
                                coordinates: viewModel.uiState.item.coordinates ?? Coordinates(x: 0, y: 0, z: 0)
                            )
                            .navigationBarTitle("BiomeFinder"),
                        isActive: $isBiomeFinderView,
                        label: { Text("") }
                    )
                    VStack(spacing: 0) {
                        SeedCardView(
                            seed: viewModel.item.seed,
                            image: $seedImage
                        )

                        CoordinatesCardView(
                            coordinates: viewModel.item.coordinates,
                            image: $coordinatesImage
                        )

                        Button {
                            isBiomeFinderView.toggle()
                        } label: {
                            Text("Show Biome Finder")
                        }
                        .frame(height: 200)
                        .accentColor(.gray)
                        .buttonStyle(OutlineButton())
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitle(Text("Seed And Coordinates Getter"))
            .onChange(of: seedImage) { image in
                guard let image else { return }
                viewModel.clearSeed()
                viewModel.getSeed(image: image)
            }
            .onChange(of: coordinatesImage) { image in
                guard let image else { return }
                viewModel.clearCoordinates()
                viewModel.getCoordinates(image: image)
            }
            .onChange(of: viewModel.uiState) { [oldState = viewModel.uiState] newState in
//                if oldState.item.seed != newState.item.seed {
//                    seed = newState.item.seed
//                }
//                if oldState.item.coordinates != newState.item.coordinates {
//                    coordinates = newState.item.coordinates
//                }
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
