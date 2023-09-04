//
//  Created by takayuki.yokoda on 2023/07/03.
//

import SwiftUI

struct EditItemView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: EditItemViewModel
    let onTapDelete: ((Item) -> Void)?
    let onTapDismiss: ((Item) -> Void)?

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
                    .padding(.top)
                }
                VStack {
                    Spacer()
                    HStack {
                        if case .update = viewModel.uiState.editMode {
                            Button(action: {
                                viewModel.delete()
                                onTapDelete?(viewModel.createItem())
                                dismiss()
                            }) {
                                Text("削除する")
                                    .bold()
                                    .frame(height: 50)
                            }
                            .foregroundColor(.red)
                            .padding(.horizontal)
                        }

                        Button(action: {
                            Task {
                                await viewModel.saveImage()
                                await viewModel.insertOrUpdate()
                                onTapDismiss?(viewModel.createItem())
                                dismiss()
                            }
                        }) {
                            Text(viewModel.uiState.editMode.button)
                                .bold()
                                .frame(height: 50)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(RoundedButtonStyle(color: .red))
                    }
                }
                .padding()
            }
            .task {
                await viewModel.loadImage()
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
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    init(item: Item? = nil, onTapDelete: ((Item) -> Void)? = nil, onTapDismiss: ((Item) -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: EditItemViewModel(item: item))
        self.onTapDelete = onTapDelete
        self.onTapDismiss = onTapDismiss
    }
}

#Preview {
    EditItemView(
        item:
        Item(
            id: "",
            coordinates: Coordinates(x: 100, y: 20, z: 300),
            seed: Seed(rawValue: 500),
            createdAt: Date(),
            updatedAt: Date()
        )
    )
}

#Preview {
    EditItemView()
}
