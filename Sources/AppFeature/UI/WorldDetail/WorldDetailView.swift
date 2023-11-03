//
//  Created by yoko-yan on 2023/10/08
//

import Core
import SwiftUI

struct WorldDetailView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: WorldDetailViewModel
    @State private var isEditView = false
    @State private var isBiomeFinderView = false

    var body: some View {
        ZStack {
            ScrollView {
                titleCell

                seedCell

                Divider()

                searchButtonForBiomeFinderCell

                editButtonCell
            }
        }
        .navigationBarTitle("World Details", displayMode: .inline)
//        .toolbar {
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Button(action: {
//                    isEditView.toggle()
//                }) {
//                    HStack {
//                        Text("Edit", bundle: .module)
//                    }
//                }
//            }
//        }
        .toolbarBackground(.visible, for: .navigationBar)
        .sheet(isPresented: $isBiomeFinderView) {
            BiomeFinderView(
                seed: viewModel.uiState.world.seed?.rawValue ?? 0,
                coordinates: Coordinates.zero
            )
        }
        .sheet(isPresented: $isEditView) {
            WorldEditView(
                world: viewModel.uiState.world,
                onTapDelete: { _ in
                    dismiss()
                }, onTapDismiss: { world in
                    viewModel.reload(world: world)
                }
            )
        }
        .analyticsScreen(name: "WorldDetailView", class: String(describing: type(of: self)))
    }

    init(world: World) {
        _viewModel = StateObject(wrappedValue: WorldDetailViewModel(world: world))
    }
}

// MARK: - Privates

private extension WorldDetailView {
    @ViewBuilder
    var titleCell: some View {
        HStack {
            Text("Title", bundle: .module)
            Spacer()
            Text(viewModel.uiState.world.name ?? "")
        }
        .padding()
    }

    var seedCell: some View {
        HStack {
            Text("Seed", bundle: .module)
            Spacer()
            Text(viewModel.uiState.world.seed?.text ?? "")
        }
        .padding()
    }

    @ViewBuilder
    var searchButtonForBiomeFinderCell: some View {
        Button {
            isBiomeFinderView.toggle()
        } label: {
            Text("Search for biomes", bundle: .module)
                .bold()
                .frame(height: 50)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(OutlineButtonStyle(color: .green))
        .padding(.horizontal)
        .padding(.top)

        Text("Search for biomes from a seed value", bundle: .module)
            .font(.caption)
            .foregroundColor(.green)
            .frame(maxWidth: .infinity)
    }

    var editButtonCell: some View {
        Button(action: {
            isEditView.toggle()
        }) {
            Text("Edit", bundle: .module)
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
    WorldDetailView(
        world: World(
            id: UUID().uuidString,
            name: "自分の世界",
            seed: .zero,
            createdAt: Date(),
            updatedAt: Date()
        )
    )
}
