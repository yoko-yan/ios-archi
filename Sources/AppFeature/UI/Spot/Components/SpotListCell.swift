//
//  Created by apla on 2023/10/08
//

import SwiftUI

struct SpotListCell: View {
    @Environment(\.colorScheme) var colorScheme
    let item: Item
    let image: UIImage?

    var body: some View {
        ZStack(alignment: .leading) {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(1, contentMode: .fill)
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
            VStack {
                Spacer()
                ZStack {
                    VStack {
                        Spacer()
                        Color.black
                            .frame(width: .infinity)
                            .frame(maxHeight: 14)
                            .opacity(0.5)
                    }
                    VStack(alignment: .leading) {
                        Spacer()
                        Text(item.coordinates?.text ?? "-")
                            .font(.caption2)
                    }
                    .foregroundColor(.white)
                }
            }
            .padding(.bottom)
        }
    }
}

#Preview {
    SpotListCell(
        item: Item(
            id: UUID().uuidString,
            coordinates: Coordinates(x: 100, y: 20, z: 300),
            world: nil,
            createdAt: Date(),
            updatedAt: Date()
        ),
        image: UIImage(named: "sample-coordinates", in: Bundle.module, with: nil)
    )
}

#Preview {
    SpotListCell(
        item: Item(
            id: UUID().uuidString,
            coordinates: Coordinates(x: 100, y: 20, z: 300),
            world: nil,
            createdAt: Date(),
            updatedAt: Date()
        ),
        image: nil
    )
}
