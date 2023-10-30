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
                HStack {
                    Spacer()
                    Text("未選択")
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selected = nil
                    dismiss()
                }
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

#if DEBUG
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
                seed: .preview,
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
#endif
