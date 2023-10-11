//
//  Created by yokoda.takayuki on 2023/07/05
//

import SwiftUI

struct WorldListCell: View {
    @Environment(\.colorScheme) var colorScheme
    let seed: Seed

    var body: some View {
        VStack {
            HStack {
                Label("seed", systemImage: "globe.desk")
                Spacer()
                Text(seed.text)
            }
        }
    }
}

#Preview {
    WorldListCell(seed: Seed(rawValue: 500)!) // swiftlint:disable:this force_unwrapping
}
