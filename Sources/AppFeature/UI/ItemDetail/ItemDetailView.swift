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
                    Text("画像なし")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .contentShape(Rectangle())
                        .frame(height: 200)
                        .background(
                            Color.gray
                                .opacity(0.1)
                        )
                }

                CoordinatesView(
                    coordinates: viewModel.uiState.item.coordinates
                )
                .padding(.top, 4)
                .padding(.horizontal)

                SeedView(
                    seed: viewModel.uiState.item.world?.seed
                )
                .padding(.horizontal)

                Divider()

                Button {
                    isBiomeFinderView.toggle()
                } label: {
                    Text("座標とシード値からバイオームを検索")
                        .bold()
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(OutlineButtonStyle(color: .green))
                .padding(.horizontal)

                Button(action: {
                    isEditView.toggle()
                }) {
                    Text("編集する")
                        .bold()
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(RoundedButtonStyle(color: .green))
                .padding(.horizontal)
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
