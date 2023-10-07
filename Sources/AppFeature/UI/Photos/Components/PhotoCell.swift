//
//  Created by takayuki.yokoda on 2023/10/07
//

import SwiftUI

struct PhotoCell: View {
    @Environment(\.colorScheme) var colorScheme
    let item: Item
    let image: UIImage?

    var body: some View {
        ZStack(alignment: .leading) {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(4 / 3, contentMode: .fill)
            } else {
                Text("画像なし")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(
                        colorScheme == .dark ? Color.black : Color.white
                    )
                    .foregroundColor(.gray)
                    .aspectRatio(4 / 3, contentMode: .fill)
            }

            if item.coordinates != nil || item.coordinates != nil {
                VStack {
                    Spacer()
                    ZStack {
                        VStack {
                            Spacer()
                            Color.black
                                .frame(width: .infinity)
                                .frame(maxHeight: 50)
                                .opacity(0.5)
                        }
                        HStack {
                            if let coordinates = item.coordinates {
                                HStack {
                                    Image(systemName: "location.circle")
                                    Text(coordinates.text)
                                }
                            }
                            Spacer()
                            if let seed = item.seed {
                                HStack {
                                    Image(systemName: "globe.desk")
                                    Text(seed.text)
                                }
                            }
                        }
                        .foregroundColor(.white)
                        .padding()
                    }
                    .frame(maxHeight: 40)
                }
            }
        }
        .modifier(CardStyle())
        .aspectRatio(4 / 3, contentMode: .fill)
    }
}

#Preview {
    PhotoCell(
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
    PhotoCell(
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
