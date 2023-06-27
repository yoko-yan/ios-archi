//
//  HomeView.swift
//  ios-archi
//
//  Created by yokoda.takayuki on 2023/01/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    @State private var seedImage: UIImage?
    @State private var positionImage: UIImage?
    @State private var seed: Seed?
    @State private var position: Position?
    @State private var isBiomeFinderView = false

    var body: some View {
        // swiftlint:disable:next closure_body_length
        NavigationView {
            // swiftlint:disable:next closure_body_length
            ScrollView {
                ZStack {
                    NavigationLink(
                        destination:
                        BiomeFinderView(
                            seed: viewModel.uiState.seed?.rawValue ?? 0,
                            positionX: viewModel.uiState.position?.x ?? 0,
                            positionZ: viewModel.uiState.position?.z ?? 0
                        )
                        .navigationBarTitle("BiomeFinder"),
                        isActive: $isBiomeFinderView,
                        label: { Text("") }
                    )
                    VStack(spacing: 0) {
                        SeedCardView(
                            seed: $seed,
                            image: $seedImage
                        )

                        PositionCardView(
                            position: $position,
                            image: $positionImage
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
            .navigationBarTitle(Text("Seed And Position Getter"))
            .onChange(of: seedImage) { image in
                guard let image else { return }
                viewModel.clearSeed()
                viewModel.getSeed(image: image)
            }
            .onChange(of: positionImage) { image in
                guard let image else { return }
                viewModel.clearPosition()
                viewModel.getPosition(image: image)
            }
            .onChange(of: viewModel.uiState) { [oldState = viewModel.uiState] newState in
                if oldState.seed != newState.seed {
                    seed = newState.seed
                }
                if oldState.position != newState.position {
                    position = newState.position
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
