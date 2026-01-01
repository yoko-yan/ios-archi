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

    private var hasImage: Bool {
        item.spotImageName != nil
    }

    var body: some View {
        LazyVStack {
            Group {
                if hasImage {
                    Rectangle()
                        .fill(colorScheme == .dark ? Color.black : Color.clear)
                        .aspectRatio(containerAspectRatio, contentMode: .fit)
                        .overlay(imageOverlay)
                } else {
                    Rectangle()
                        .fill(colorScheme == .dark ? Color.black : Color.gray.opacity(0.3))
                        .frame(height: 70)
                        .overlay(infoOverlay)
                }
            }
            .modifier(CardStyle())
            .task {
                onLoadImage?(item)
            }
        }
    }

    @ViewBuilder
    private var imageOverlay: some View {
        ZStack {
            if let uiImage = spotImage?.image {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            } else if spotImage?.isLoading == true {
                ProgressView()
                    .tint(.gray)
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
                    infoContent
                }
            }
        }
    }

    private var infoOverlay: some View {
        ZStack {
            Color.black
                .opacity(0.5)

            infoContent
        }
        .frame(height: 70)
    }

    private var infoContent: some View {
        VStack {
            Spacer()
            HStack {
                Image(systemName: "location.circle")
                Text(item.coordinates?.textWitWhitespaces ?? "-")
                Spacer()
            }
            HStack {
                Image(systemName: "globe.desk")
                Text(worldText)
                Spacer()
            }
        }
        .foregroundColor(.white)
        .padding()
    }

    private var worldText: String {
        if let title = item.world?.name {
            return title
        } else if let seed = item.world?.seed?.text {
            return seed
        }
        return "-"
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
