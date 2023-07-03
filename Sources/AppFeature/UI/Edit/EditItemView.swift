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
            ZStack {
                ScrollView {
                    VStack(spacing: 10) {
                        CoordinatesEditView(
                            coordinates: viewModel.input.coordinates,
                            image: viewModel.coordinatesImage
                        )

                        Divider()

                        SeedEditView(
                            seed: viewModel.input.seed,
                            image: viewModel.seedImage
                        )

                        Color.clear
                            .frame(height: 100)
                    }
                }
                VStack {
                    Spacer()
                    Button(action: {
                        let editMode = viewModel.uiState.editMode
                        viewModel.saveImage()
                        if case .add = editMode {
                            viewModel.insertItem()
                        } else if case .update = editMode {
                            viewModel.updateItem()
                        }
                        dismiss()

                    }) {
                        Text(viewModel.uiState.editMode.button)
                            .bold()
                            .frame(height: 50)
                            .frame(maxWidth: .infinity)
                    }
                    .accentColor(Color.white)
                    .background(Color.orange)
                    .cornerRadius(8)
                }
                .padding()
            }
            .task {
                viewModel.loadImage()
            }
            .onChange(of: viewModel.uiState) { [oldState = viewModel.uiState] newState in
                if let coordinatesImage = newState.coordinatesImage, oldState.coordinatesImage != coordinatesImage
                {
                    viewModel.getCoordinates(image: coordinatesImage)
                }
                if let seedImage = newState.seedImage, oldState.seedImage != seedImage {
                    viewModel.getSeed(image: seedImage)
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
            }
        }
    }

    init(item: Item? = nil) {
        _viewModel = StateObject(wrappedValue: EditItemViewModel(item: item))
    }
}

// struct EditItemView_Previews: PreviewProvider {
//    static var previews: some View {
//        EditItemView()
//        EditItemView(
//            item:
//                EditItemUiState.EditItem(
//                    coordinates: Coordinates(x: 100, y: 20, z: 300),
//                    seed: Seed(rawValue: 500)
//                )
//        )
//    }
// }
