//
//  Created by takayuki.yokoda on 2023/07/03.
//

import SwiftUI

import Combine
import SwiftUI

struct CoordinatesView: View {
    let coordinates: Coordinates?
    let image: UIImage?

    var body: some View {
        VStack {
            HStack {
                Label("coordinates", systemImage: "location.circle")
                Spacer()
                Text(coordinates?.text ?? "未登録")
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
    CoordinatesView(
        coordinates: .init(x: 200, y: 0, z: -100),
        image: UIImage(named: "sample-coordinates", in: Bundle.module, with: nil)
    )
}

#Preview {
    CoordinatesView(
        coordinates: nil,
        image: nil
    )
}
