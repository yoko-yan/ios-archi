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
                spotImageCell

                coordinatesCell

                worldCell

                searchButtonForBiomeFinderCell

                editButtonCell
            }
        }
        .navigationBarTitle("Spot Details", displayMode: .inline)
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

// MARK: - Privates

private extension ItemDetailView {
    @ViewBuilder
    var spotImageCell: some View {
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
    }

    var coordinatesCell: some View {
        HStack {
            Text("Coordinates")
            Spacer()
            Text(viewModel.uiState.item.coordinates?.textWitWhitespaces ?? "Unregistered")
        }
        .padding()
    }

    @ViewBuilder
    var worldCell: some View {
        if let world = viewModel.uiState.item.world {
            Label("World", systemImage: "globe.desk")
                .frame(height: 30)
                .frame(maxWidth: .infinity)
                .foregroundColor(.white)
                .background(.gray)

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
    }

    @ViewBuilder
    var searchButtonForBiomeFinderCell: some View {
        Button {
            isBiomeFinderView.toggle()
        } label: {
            Text("Search for biomes")
                .bold()
                .frame(height: 50)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(OutlineButtonStyle(color: .green))
        .padding(.horizontal)
        .padding(.top)

        Text("Search for biomes from a seed value and coordinates")
            .font(.caption)
            .foregroundColor(.green)
            .frame(maxWidth: .infinity)
    }

    var editButtonCell: some View {
        Button(action: {
            isEditView.toggle()
        }) {
            Text("Edit")
                .bold()
                .frame(height: 50)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(RoundedButtonStyle(color: .green))
        .padding()
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
