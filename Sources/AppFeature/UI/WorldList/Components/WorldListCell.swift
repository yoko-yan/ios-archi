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
                    .bold()
            }
        }
    }
}

#Preview {
    WorldListCell(seed: Seed(rawValue: 500)!)
}
