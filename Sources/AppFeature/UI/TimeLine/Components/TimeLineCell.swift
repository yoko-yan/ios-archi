//
//  Created by takayuki.yokoda on 2023/10/07
//

import SwiftUI

struct TimeLineCell: View {
    @Environment(\.colorScheme) var colorScheme
    let item: Item
//    let image: UIImage?

    var body: some View {
        Rectangle()
            .aspectRatio(1, contentMode: .fit)
            .overlay(
                ZStack {
                    LazyVStack {
                        if let spotImageName = item.spotImageName {
                            //                        Image(uiImage: image)
                            //                            .resizable()
                            //                            .scaledToFit()
                            //                        SyncImage(fileName: spotImageName)
                            let url = FileManager.default.url(forUbiquityContainerIdentifier: nil)!
                                .appendingPathComponent("Documents")
                                .appendingPathComponent(spotImageName)
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                            } placeholder: {
                                ProgressView()
                            }
                        } else {
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

// #Preview {
//    TimeLineCell(
//        item:
//        Item(
//            id: UUID().uuidString,
//            coordinates: Coordinates(x: 100, y: 20, z: 300),
//            world: nil,
//            createdAt: Date(),
//            updatedAt: Date()
//        ),
//        image: UIImage(named: "sample-coordinates", in: Bundle.module, with: nil)
//    )
// }
//
// #Preview {
//    TimeLineCell(
//        item:
//        Item(
//            id: UUID().uuidString,
//            coordinates: Coordinates(x: 100, y: 20, z: 300),
//            world: nil,
//            createdAt: Date(),
//            updatedAt: Date()
//        ),
//        image: nil
//    )
// }
