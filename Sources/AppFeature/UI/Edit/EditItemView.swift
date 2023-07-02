//
//  EditItemView.swift
//
//
//  Created by takayuki.yokoda on 2023/07/03.
//

import SwiftUI

struct EditItemView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: EditItemViewModel

    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    VStack(spacing: 10) {
                        SeedEditView(
                            seed: viewModel.editItem.seed,
                            image: viewModel.seedImage
                        )

                        Divider()

                        CoordinatesEditView(
                            coordinates: viewModel.editItem.coordinates,
                            image: viewModel.coordinatesImage
                        )
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
            .navigationBarTitle(viewModel.uiState.editMode.title, displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.updateItem()
                        dismiss()
                    }) {
                        HStack {
                            Text(viewModel.uiState.editMode.button)
                        }
                    }
                }
            }
        }
    }

    init(item: Item? = nil) {
        _viewModel = StateObject(wrappedValue: EditItemViewModel(item: item))
    }
}

struct EditItemView_Previews: PreviewProvider {
    static var previews: some View {
        EditItemView()
        EditItemView(
            item:
            Item(
                seed: Seed(rawValue: 500),
                coordinates: Coordinates(x: 100, y: 20, z: 300)
            )
        )
    }
}
