//
//  Created by apla on 2023/10/08
//

import SwiftUI

struct WorldSelectionView: View {
    @Environment(\.dismiss) var dismiss

    let worlds: [World]
    @Binding var selected: World?

    var body: some View {
        ZStack {
            List {
                ForEach(worlds, id: \.self) { world in
                    WorldListCell(world: world)
                        .onTapGesture {
                            selected = world
                            dismiss()
                        }
                }
            }
            .listStyle(.plain)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitle(Text("ワールドを選択する"))
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

// MARK: - Previews

#Preview {
    WorldSelectionView(
        worlds: [
            World(
                id: "1",
                name: "自分の世界",
                seed: .zero,
                createdAt: Date(),
                updatedAt: Date()
            ),
            World(
                id: "2",
                name: "自分の世界",
                seed: .zero,
                createdAt: Date(),
                updatedAt: Date()
            )
        ],
        selected: .constant(
            World(
                id: "1",
                name: "自分の世界",
                seed: .zero,
                createdAt: Date(),
                updatedAt: Date()
            )
        )
    )
}
