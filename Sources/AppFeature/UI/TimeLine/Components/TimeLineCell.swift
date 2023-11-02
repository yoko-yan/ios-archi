//
//  Created by yoko-yan on 2023/10/07
//

import SwiftUI

struct TimeLineCell: View {
    @Environment(\.colorScheme) private var colorScheme

    let item: Item
    let spotImage: SpotImage?
    let onLoadImage: ((Item) -> Void)?

    var body: some View {
        LazyVStack {
            Rectangle()
                .aspectRatio(1, contentMode: .fit)
                .overlay(
                    ZStack {
                        if let uiImage = spotImage?.image {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                        } else {
                            Rectangle()
                                .fill(colorScheme == .dark ? Color.black : Color.white)
                                .aspectRatio(contentMode: .fit)
                            Text("No photo available")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .foregroundColor(.gray)
                        }

                        VStack {
                            Spacer()
                            ZStack {
                                VStack {
                                    Spacer()
                                    Color.black
                                        .frame(maxHeight: 70)
                                        .opacity(0.5)
                                }
                                VStack {
                                    Spacer()
                                    HStack {
                                        Image(systemName: "location.circle")
                                        Text(item.coordinates?.textWitWhitespaces ?? "-")
                                        Spacer()
                                    }
                                    HStack {
                                        Image(systemName: "globe.desk")
                                        var world: String? {
                                            if let title = item.world?.name {
                                                return title
                                            } else if let seed = item.world?.seed?.text {
                                                return seed
                                            }
                                            return nil
                                        }
                                        Text(world ?? "-")
                                        Spacer()
                                    }
                                }
                                .foregroundColor(.white)
                                .padding()
                            }
                        }
                    }
                )
                .modifier(CardStyle())
                .task {
                    onLoadImage?(item)
                }
        }
    }
}

// MARK: - Previews

#Preview {
    TimeLineCell(
        item:
        Item(
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
    TimeLineCell(
        item:
        Item(
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

struct TimeLineCell_Previews: PreviewProvider {
    static var previews: some View {
        TimeLineCell(
            item:
            Item(
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
