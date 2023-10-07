//
//  Created by takayuki.yokoda on 2023/10/07
//

import SwiftUI

struct TimeLineCell: View {
    @Environment(\.colorScheme) var colorScheme
    let item: Item
    let image: UIImage?

    var body: some View {
        ZStack(alignment: .leading) {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Text("画像なし")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(
                        colorScheme == .dark ? Color.black : Color.white
                    )
                    .foregroundColor(.gray)
                    .aspectRatio(1, contentMode: /*@START_MENU_TOKEN@*/ .fill/*@END_MENU_TOKEN@*/)
            }

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
                        HStack {
                            Image(systemName: "location.circle")
                            Text(item.coordinates?.text ?? "-")
                        }
                        Spacer()
                        HStack {
                            Image(systemName: "globe.desk")
                            Text(item.seed?.text ?? "-")
                        }
                    }
                    .foregroundColor(.white)
                    .padding()
                }
                .frame(maxHeight: 40)
            }
        }
        .modifier(CardStyle())
    }
}

#Preview {
    TimeLineCell(
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
    TimeLineCell(
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
