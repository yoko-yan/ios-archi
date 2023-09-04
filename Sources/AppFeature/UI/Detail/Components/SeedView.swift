//
//  Created by yokoda.takayuki on 2023/01/29.
//

import Combine
import SwiftUI

struct SeedView: View {
    let seed: Seed?
    let image: UIImage?

    var body: some View {
        VStack {
            HStack {
                Label("seed", systemImage: "globe.desk")
                Spacer()
                Text(seed?.text ?? "未登録")
                    .bold()
            }
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            }
        }
        .padding()
    }
}

#Preview {
    SeedView(
        seed: Seed(rawValue: 1234567890),
        image: UIImage(named: "sample-seed", in: Bundle.module, with: nil)!
    )
}

#Preview {
    SeedView(
        seed: nil,
        image: nil
    )
}
