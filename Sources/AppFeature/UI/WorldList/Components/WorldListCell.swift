//
//  Created by yokoda.takayuki on 2023/07/05
//

import SwiftUI

struct WorldListCell: View {
    @Environment(\.colorScheme) var colorScheme
    let world: World

    var body: some View {
        VStack {
            HStack {
                Label("seed", systemImage: "globe.desk")
                Spacer()
                Text(world.seed?.text ?? "")
            }
        }
    }
}

// MARK: - Previews

#Preview {
    WorldListCell(
        world: World(
            id: "",
            name: "aaa",
            seed: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
    )
}
