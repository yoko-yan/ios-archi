//
//  Created by yokoda.takayuki on 2023/07/05
//

import SwiftUI

struct WorldListCell: View {
    @Environment(\.colorScheme) var colorScheme
    let seed: Seed

    var body: some View {
        VStack(alignment: .leading) {
            Text(seed.text)
        }
    }
}

#Preview {
    WorldListCell(seed: Seed(rawValue: 500)!)
}
