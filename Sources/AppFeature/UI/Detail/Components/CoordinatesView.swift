//
//  Created by takayuki.yokoda on 2023/07/03.
//

import SwiftUI

import Combine
import SwiftUI

struct CoordinatesView: View {
    let coordinates: Coordinates?

    var body: some View {
        HStack {
            Label("coordinates", systemImage: "location.circle")
            Spacer()
            Text(coordinates?.text ?? "未登録")
                .bold()
        }
    }
}

#Preview {
    CoordinatesView(
        coordinates: .init(x: 200, y: 0, z: -100)
    )
}

#Preview {
    CoordinatesView(
        coordinates: nil
    )
}
