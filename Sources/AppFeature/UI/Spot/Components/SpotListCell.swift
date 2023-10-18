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
                Rectangle()
                    .aspectRatio(1, contentMode: .fit)
                    .overlay(
                        Image(uiImage: image)
                            .resizable()
                    )
                    .cornerRadius(8.0)
                    .clipped()
            } else {
                Rectangle()
                    .fill(colorScheme == .dark ? Color.black : Color.white)
                    .aspectRatio(contentMode: .fit)
                Text("画像なし")
                    .font(.caption2)
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

            if let coordinates = item.coordinates {
                VStack {
                    Spacer()
                    ZStack {
                        VStack {
                            Spacer()
                            Color.black
                                .frame(maxHeight: 14)
                                .opacity(0.5)
                        }
                        VStack(alignment: .leading) {
                            Spacer()
                            Text(coordinates.text)
                                .font(.caption2)
                        }
                        .foregroundColor(.white)
                    }
                }
                .padding(.bottom, 8)
            }
        }
    }
}

// MARK: - Previews

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
