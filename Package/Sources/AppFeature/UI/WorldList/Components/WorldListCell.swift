//
//  Created by yokoda.takayuki on 2023/07/05
//

import SwiftUI

struct WorldListCell: View {
    @Environment(\.colorScheme) private var colorScheme
    let world: World?

    var body: some View {
        HStack {
            Image(systemName: "globe.desk")
            VStack {
                if let name = world?.name, !name.isEmpty {
                    HStack {
                        Text(name)
                            .font(.headline)
                        Spacer()
                    }
                }
                if let seed = world?.seed {
                    HStack {
                        Text("Seed", bundle: .module)
                            .font(.subheadline)
                        Spacer()
                        Text(seed.text)
                            .font(.subheadline)
                    }
                }
            }
        }
        .contentShape(Rectangle())
    }
}

// MARK: - Previews

#if DEBUG
@available(iOS 17.0, *)
#Preview(traits: .fixedLayout(width: 375, height: 40)) {
    WorldListCell(world: .preview)
}

@available(iOS 17.0, *)
#Preview(traits: .fixedLayout(width: 375, height: 40)) {
    WorldListCell(world: .previewWithOutName)
}

@available(iOS 17.0, *)
#Preview(traits: .fixedLayout(width: 375, height: 40)) {
    WorldListCell(world: .previewWithOutSeed)
}
#endif
