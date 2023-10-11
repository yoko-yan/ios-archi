//
//  Created by apla on 2023/10/08
//

import SwiftUI

struct WorldSelectionView: View {
    @Environment(\.dismiss) var dismiss

    let worlds: [World]
    var selected: World?
    var selectedAction: ((_ selected: World) -> Void)?

    var body: some View {
        ZStack {
            List {
                ForEach(worlds, id: \.self) { world in
                    WorldListCell(world: world)
                        .padding(.top)
                        .onTapGesture {
                            if let selectedAction {
                                selectedAction(world)
                            }
                            dismiss()
                        }
                }
            }
            .listStyle(.plain)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitle(Text("ワールド一覧"))
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

#Preview {
    WorldSelectionView(worlds: [])
}
