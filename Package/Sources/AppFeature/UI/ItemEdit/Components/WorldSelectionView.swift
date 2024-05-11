import SwiftUI

struct WorldSelectionView: View {
    @Environment(\.colorScheme) private var colorScheme
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

                HStack {
                    if selected != nil {
                        Button(action: {
                            selected = nil
                            dismiss()
                        }) {
                            Text("Deselect", bundle: .module)
                                .bold()
                                .frame(height: 40)
                                .padding(.horizontal)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.black, lineWidth: 1)
                                )
                        }
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    }
                    Button(action: {
                        isShowDetailView.toggle()
                    }) {
                        Label(String(localized: "Register a world", bundle: .module), systemImage: "globe.desk")
                            .bold()
                            .frame(height: 40)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(RoundedButtonStyle(color: .black))
                }
            }
            .listStyle(.plain)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitle(Text("Select a world", bundle: .module))
        .toolbarBackground(.visible, for: .navigationBar)
        .sheet(isPresented: $isShowDetailView) {
            WorldEditView(
                onTapDismiss: { newValue in
                    worlds.append(newValue)
                }
            )
            .presentationDetents([.medium, .large])
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
