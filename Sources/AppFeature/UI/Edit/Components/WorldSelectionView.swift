//
//  Created by apla on 2023/10/08
//

import SwiftUI

struct WorldSelectionView: View {
    @Environment(\.dismiss) var dismiss

    let items: [Seed]
    var selected: Seed?
    var selectedAction: ((_ selected: Seed) -> Void)?

    var body: some View {
        ZStack {
            List {
                ForEach(items, id: \.self) { seed in
                    WorldListCell(seed: seed)
                        .padding(.top)
                        .onTapGesture {
                            if let selectedAction {
                                selectedAction(seed)
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
    WorldSelectionView(items: [])
}
