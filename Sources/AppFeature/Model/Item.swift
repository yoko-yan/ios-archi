//
//  Created by yoko-yan on 2023/07/01.
//

import Foundation

struct Item: Identifiable, Hashable {
    let id: String
    let coordinates: Coordinates?
    let world: World?
    let spotImageName: String?
    let createdAt: Date
    let updatedAt: Date
}

#if DEBUG
extension Item {
    static var preview: Self {
        Item(
            id: UUID().uuidString,
            coordinates: Coordinates(x: 100, y: 20, z: 300),
            world: nil,
            spotImageName: "sample-coordinates",
            createdAt: Date(),
            updatedAt: Date()
        )
    }

    static var previewWithImage: Self {
        Item(
            id: UUID().uuidString,
            coordinates: Coordinates(x: 200, y: 30, z: 400),
            world: nil,
            spotImageName: "sample-seed",
            createdAt: Date(),
            updatedAt: Date()
        )
    }

    static var previewWithNoImage: Self {
        Item(
            id: UUID().uuidString,
            coordinates: Coordinates(x: 300, y: 40, z: 500),
            world: nil,
            spotImageName: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}
#endif
