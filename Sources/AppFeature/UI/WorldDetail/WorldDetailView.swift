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
                HStack {
                    Text("name")
                    Spacer()
                    Text(viewModel.uiState.world.name ?? "")
                }
                .padding()

                HStack {
                    Text("seed")
                    Spacer()
                    Text(viewModel.uiState.world.seed?.text ?? "")
                }
                .padding()

                Divider()

                Button {
                    isBiomeFinderView.toggle()
                } label: {
                    Text("シード値からバイオームを検索")
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
