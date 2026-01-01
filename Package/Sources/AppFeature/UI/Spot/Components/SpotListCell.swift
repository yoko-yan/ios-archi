import SwiftUI

struct SpotListCell: View {
    @Environment(\.colorScheme) private var colorScheme

    let item: Item
    let spotImage: SpotImage?
    let onLoadImage: ((Item) -> Void)?

    var body: some View {
        Rectangle()
            .fill(colorScheme == .dark ? Color.black : Color.clear)
            .aspectRatio(1, contentMode: .fit)
            .overlay(
                ZStack(alignment: .leading) {
                    if let uiImage = spotImage?.image {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                    } else if spotImage?.isLoading == true {
                        ZStack {
                            Rectangle()
                                .fill(colorScheme == .dark ? Color.black : Color.clear)
                            ProgressView()
                                .tint(.gray)
                        }
                    } else {
                        Rectangle()
                            .fill(colorScheme == .dark ? Color.black : Color.white)
                            .aspectRatio(contentMode: .fit)
                        Text("No photo available", bundle: .module)
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
                                    Text(coordinates.textWitWhitespaces)
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

#Preview(traits: .fixedLayout(width: 375, height: 100)) {
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
