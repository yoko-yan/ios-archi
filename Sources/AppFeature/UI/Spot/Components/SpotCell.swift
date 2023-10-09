//
//  Created by apla on 2023/10/08
//

import SwiftUI

struct SpotCell: View {
    @Environment(\.colorScheme) var colorScheme
    let item: Item
    let image: UIImage?

    var body: some View {
        ZStack(alignment: .leading) {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(1, contentMode: /*@START_MENU_TOKEN@*/ .fill/*@END_MENU_TOKEN@*/)
                    .cornerRadius(8.0)
            } else {
                Text("画像なし")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(
                        colorScheme == .dark ? Color.black : Color.white
                    )
                    .foregroundColor(.gray)
                    .cornerRadius(8.0)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8.0)
                            .stroke(Color.gray, lineWidth: 0.5)
                    )
            }
        }
    }
}

#Preview {
    SpotCell(
        item:
        Item(
            id: UUID().uuidString,
            coordinates: Coordinates(x: 100, y: 20, z: 300),
            seed: Seed(rawValue: 500),
            createdAt: Date(),
            updatedAt: Date()
        ),
        image: UIImage(named: "sample-coordinates", in: Bundle.module, with: nil)
    )
}

#Preview {
    SpotCell(
        item:
        Item(
            id: UUID().uuidString,
            coordinates: Coordinates(x: 100, y: 20, z: 300),
            seed: Seed(rawValue: 500),
            createdAt: Date(),
            updatedAt: Date()
        ),
        image: nil
    )
}
