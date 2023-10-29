//
//  Created by yoko-yan on 2023/10/08
//

import SwiftUI

struct SpotListCell: View {
    @Environment(\.colorScheme) private var colorScheme

    let item: Item
    let spotImage: SpotImage?
    let onLoadImage: ((Item) -> Void)?

    var body: some View {
        Rectangle()
            .aspectRatio(1, contentMode: .fit)
            .overlay(
                ZStack(alignment: .leading) {
                    if let uiImage = spotImage?.image {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                    } else {
                        Rectangle()
                            .fill(colorScheme == .dark ? Color.black : Color.white)
                            .aspectRatio(contentMode: .fit)
                        Text("画像なし")
                            .font(.caption2)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .foregroundColor(.gray)
                            .overlay(
                                Rectangle()
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
            )
            .task {
                onLoadImage?(item)
            }
            .clipped()
    }
}

// MARK: - Previews

#Preview {
    SpotListCell(
        item: Item(
            id: UUID().uuidString,
            coordinates: Coordinates(x: 100, y: 20, z: 300),
            world: nil,
            spotImageName: nil,
            createdAt: Date(),
            updatedAt: Date()
        ),
        spotImage: nil,
        onLoadImage: nil
    )
}

#Preview {
    SpotListCell(
        item: Item(
            id: UUID().uuidString,
            coordinates: Coordinates(x: 100, y: 20, z: 300),
            world: nil,
            spotImageName: nil,
            createdAt: Date(),
            updatedAt: Date()
        ),
        spotImage: nil,
        onLoadImage: nil
    )
    .previewLayout(.fixed(width: 375, height: 100))
}

struct SpotListCell_Previews: PreviewProvider {
    static var previews: some View {
        SpotListCell(
            item: Item(
                id: UUID().uuidString,
                coordinates: Coordinates(x: 100, y: 20, z: 300),
                world: nil,
                spotImageName: nil,
                createdAt: Date(),
                updatedAt: Date()
            ),
            spotImage: nil,
            onLoadImage: nil
        )
        .previewLayout(.sizeThatFits)
    }
}
