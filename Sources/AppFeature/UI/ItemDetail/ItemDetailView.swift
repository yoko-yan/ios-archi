//
//  Created by yoko-yan on 2023/07/01.
//

import Core
import SwiftUI

struct ItemDetailView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: ItemDetailViewModel
    @State private var isEditView = false
    @State private var isBiomeFinderView = false

    var body: some View {
        ZStack {
            ScrollView {
                if let image = viewModel.uiState.spotImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                } else {
                    Text("No photo available")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .contentShape(Rectangle())
                        .frame(height: 200)
                        .background(
                            Color.gray
                                .opacity(0.1)
                        )
                }

                HStack {
                    Text("Coordinates")
                    Spacer()
                    Text(viewModel.uiState.item.coordinates?.textWitWhitespaces ?? "Unregistered")
                }
                .padding()

                Divider()

                if let world = viewModel.uiState.item.world {
                    HStack {
                        Text("Title")
                        Spacer()
                        Text(world.name ?? "")
                    }
                    .padding()

                    HStack {
                        Text("Seed")
                        Spacer()
                        Text(world.seed?.text ?? "")
                    }
                    .padding()

                    Divider()
                }

                Button {
                    isBiomeFinderView.toggle()
                } label: {
                    Text("Search for biomes from a seed value and coordinates")
                        .bold()
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(OutlineButtonStyle(color: .green))
                .padding(.horizontal)

                Button(action: {
                    isEditView.toggle()
                }) {
                    Text("Edit")
                        .bold()
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(RoundedButtonStyle(color: .green))
                .padding(.horizontal)
            }
        }
        .navigationBarTitle("Details", displayMode: .inline)
//        .toolbar {
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Button(action: {
//                    isEditView.toggle()
//                }) {
//                    HStack {
//                        Text("Edit")
//                    }
//                }
//            }
//        }
        .toolbarBackground(.visible, for: .navigationBar)
        .task {
            viewModel.loadImage()
        }
        .sheet(isPresented: $isBiomeFinderView) {
            BiomeFinderView(
                seed: viewModel.uiState.item.world?.seed?.rawValue ?? 0,
                coordinates: viewModel.uiState.item.coordinates ?? Coordinates.zero
            )
        }
        .sheet(isPresented: $isEditView) {
            ItemEditView(
                item: viewModel.uiState.item,
                onDelete: { _ in
                    dismiss()
                }, onChange: { item in
                    viewModel.reload(item: item)
                }
            )
        }
        .analyticsScreen(name: "ItemDetailView", class: String(describing: type(of: self)))
    }

    init(item: Item) {
        _viewModel = StateObject(wrappedValue: ItemDetailViewModel(item: item))
    }
}

// MARK: - Previews

#Preview {
    ItemDetailView(
        item: Item(
            id: UUID().uuidString,
            coordinates: .zero,
            world: nil,
            spotImageName: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
    )
}

#Preview {
    ItemDetailView(
        item: Item(
            id: UUID().uuidString,
            coordinates: nil,
            world: nil,
            spotImageName: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
    )
}

#Preview {
    ItemDetailView(
        item: Item(
            id: UUID().uuidString,
            coordinates: Coordinates(x: 100, y: 20, z: 300),
            world: nil,
            spotImageName: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
    )
}
