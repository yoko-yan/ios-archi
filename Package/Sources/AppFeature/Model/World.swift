////
////  Created by yoko-yan on 2023/10/11
////
//
import Foundation

struct World: Identifiable, Hashable {
    let id: String
    let name: String?
    let seed: Seed?
    let createdAt: Date
    let updatedAt: Date
}

#if DEBUG
extension World {
    static var preview = Self(
        id: UUID().uuidString,
        name: "My World",
        seed: .preview,
        createdAt: Date(),
        updatedAt: Date()
    )

    static var previewWithOutName = Self(
        id: UUID().uuidString,
        name: nil,
        seed: .preview,
        createdAt: Date(),
        updatedAt: Date()
    )

    static var previewWithOutSeed = Self(
        id: UUID().uuidString,
        name: "My World",
        seed: nil,
        createdAt: Date(),
        updatedAt: Date()
    )
}
#endif
