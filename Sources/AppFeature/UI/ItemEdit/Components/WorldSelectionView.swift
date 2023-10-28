//
//  Created by yoko-yan on 2023/10/08
//

import SwiftUI

struct WorldSelectionView: View {
    @Environment(\.dismiss) var dismiss

    @State var worlds: [World]
    @Binding var selected: World?

    @State private var isShowDetailView = false

    var body: some View {
        ZStack {
            List(selection: $selected) {
                ForEach(worlds, id: \.self) { world in
                    WorldListCell(world: world)
                        .onTapGesture {
                            selected = world
                            dismiss()
                        }
                }
                VStack {
                    Button(action: {
                        isShowDetailView.toggle()
                    }) {
                        Text("ワールドを新規に追加する")
                            .bold()
                            .frame(height: 50)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(RoundedButtonStyle(color: .black))
                }
            }
            .listStyle(.plain)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitle(Text("ワールドを選択する"))
        .toolbarBackground(.visible, for: .navigationBar)
        .sheet(isPresented: $isShowDetailView) {
            WorldEditView(
                onTapDismiss: { newValue in
                    worlds.append(newValue)
                }
            )
        }
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
                seed: Seed("8362488480127410877"),
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
