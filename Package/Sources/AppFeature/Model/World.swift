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
    static var preview: Self {
        .init(
            id: UUID().uuidString,
            name: "My World",
            seed: .preview,
            createdAt: Date(),
            updatedAt: Date()
        )
    }

    static var previewWithOutName: Self {
        .init(
            id: UUID().uuidString,
            name: nil,
            seed: .preview,
            createdAt: Date(),
            updatedAt: Date()
        )
    }

    static var previewWithOutSeed: Self {
        .init(
            id: UUID().uuidString,
            name: "My World",
            seed: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}
#endif
