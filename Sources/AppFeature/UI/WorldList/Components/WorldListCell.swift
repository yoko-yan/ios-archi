//
//  Created by yokoda.takayuki on 2023/07/05
//

import SwiftUI

struct WorldListCell: View {
    @Environment(\.colorScheme) private var colorScheme
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

struct WorldListCell_Previews: PreviewProvider {
    static var previews: some View {
        WorldListCell(
            world: World(
                id: "",
                name: "aaa",
                seed: nil,
                createdAt: Date(),
                updatedAt: Date()
            )
        )
        .previewLayout(.fixed(width: 375, height: 40))
    }
}
