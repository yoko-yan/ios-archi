//
//  Created by yoko-yan on 2023/10/07
//

import SwiftUI

struct TimeLineCell: View {
    @Environment(\.colorScheme) var colorScheme
    let item: Item

    var body: some View {
        Rectangle()
            .aspectRatio(1, contentMode: .fit)
            .overlay(
                ZStack {
                    LazyVStack {
                        let url = FileManager.default.url(forUbiquityContainerIdentifier: nil)!
                            .appendingPathComponent("Documents")
                            .appendingPathComponent(item.spotImageName ?? "")
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFit()
                        } placeholder: {
                            Rectangle()
                                .fill(colorScheme == .dark ? Color.black : Color.white)
                                .aspectRatio(contentMode: .fit)
                            Text("画像なし")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .foregroundColor(.gray)
                        }
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
                                    Text(item.coordinates?.text ?? "-")
                                    Spacer()
                                }
                                HStack {
                                    Image(systemName: "globe.desk")
                                    Text(item.world?.seed?.text ?? "-")
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
            createdAt: Date(),
            updatedAt: Date()
        )
    )
}

#Preview {
    TimeLineCell(
        item:
        Item(
            id: UUID().uuidString,
            coordinates: Coordinates(x: 100, y: 20, z: 300),
            world: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
    )
}
