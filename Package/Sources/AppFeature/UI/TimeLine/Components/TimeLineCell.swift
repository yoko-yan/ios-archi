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
                    imageCardContent
                } else {
                    noImageCardContent
                }
            }
            .modifier(CardStyle())
            .task {
                onLoadImage?(item)
            }
        }
    }

    @ViewBuilder
    private var imageCardContent: some View {
        ZStack(alignment: .bottom) {
            if let uiImage = spotImage?.image {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            } else {
                Rectangle()
                    .fill(colorScheme == .dark ? Color.black : Color.gray.opacity(0.1))
                    .aspectRatio(16.0 / 9.0, contentMode: .fit)
                    .overlay {
                        if spotImage?.isLoading == true {
                            ProgressView()
                                .tint(.gray)
                        }
                    }
            }

            liquidInfoOverlay
        }
    }

    private var liquidInfoOverlay: some View {
        HStack(spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "location.fill")
                    .font(.system(size: 11, weight: .semibold))
                Text(item.coordinates?.textWitWhitespaces ?? "-")
                    .font(.system(size: 12, weight: .medium))
            }

            HStack(spacing: 6) {
                Image(systemName: "globe.americas.fill")
                    .font(.system(size: 11, weight: .semibold))
                Text(worldText)
                    .font(.system(size: 12, weight: .medium))
                    .lineLimit(1)
            }

            Spacer()
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.6),
                            Color.black.opacity(0.4)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 2)
        )
        .padding(8)
    }

    private var noImageCardContent: some View {
        LinearGradient(
            colors: colorScheme == .dark
                ? [Color.gray.opacity(0.4), Color.gray.opacity(0.2)]
                : [Color.gray.opacity(0.15), Color.gray.opacity(0.05)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .frame(height: 56)
        .overlay(alignment: .leading) {
            liquidInfoOverlay
        }
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
