import SwiftUI

struct TimeLineCell: View {
    @Environment(\.colorScheme) private var colorScheme

    let item: Item
    let spotImage: SpotImage?
    let onLoadImage: ((Item) -> Void)?
    private var containerAspectRatio: CGFloat {
        if let image = spotImage?.image {
            let ratio = image.size.width / max(image.size.height, 1)
            return max(ratio, 1)
        }
        return 16.0 / 9.0
    }

    var body: some View {
        LazyVStack {
            Rectangle()
                .aspectRatio(containerAspectRatio, contentMode: .fit)
                .overlay(
                    ZStack {
                        if let uiImage = spotImage?.image {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                        } else {
                            Rectangle()
                                .fill(colorScheme == .dark ? Color.black : Color.white)
                            Text("No photo available", bundle: .module)
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
