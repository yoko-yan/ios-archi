//
//  Created by yokoda.takayuki on 2023/01/29.
//

import Combine
import SwiftUI

struct SeedView: View {
    let seed: Seed?

    var body: some View {
        VStack {
            HStack {
                Label("seed", systemImage: "globe.desk")
                Spacer()
                Text(seed?.text ?? "未登録")
                    .bold()
            }
        }
    }
}

#Preview {
    SeedView(
        seed: Seed(rawValue: 1234567890)
    )
}

#Preview {
    SeedView(
        seed: nil
    )
}
