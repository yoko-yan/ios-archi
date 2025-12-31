import Foundation
import SwiftData

protocol ItemsSwiftDataSource: Sendable {
    func fetchAll() async throws -> [Item]
    func fetchWithoutNoPhoto() async throws -> [Item]
    func insert(_ item: Item, imageData: Data?) async throws
    func update(_ item: Item, imageData: Data?) async throws
    func delete(_ item: Item) async throws
}

@MainActor
final class ItemsSwiftDataSourceImpl: ItemsSwiftDataSource {
    private var container: ModelContainer {
        SwiftDataManager.shared.container
    }

    private let worldsDataSource: any WorldsSwiftDataSource

    init(
        worldsDataSource: some WorldsSwiftDataSource = WorldsSwiftDataSourceImpl()
    ) {
        self.worldsDataSource = worldsDataSource
    }

    func fetchAll() async throws -> [Item] {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<ItemModel>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        let models = try context.fetch(descriptor)
        print("📊 ItemsSwiftDataSource.fetchAll: fetched \(models.count) items")
        if models.isEmpty {
            print("⚠️ No items found in local store")
        } else {
            print("ℹ️ Item IDs: \(models.map(\.id).prefix(5))")
        }
        return try await models.asyncMap { try await convertToDomain($0) }
    }

    func fetchWithoutNoPhoto() async throws -> [Item] {
        let context = ModelContext(container)
        let predicate = #Predicate<ItemModel> { $0.spotImageData != nil }
        let descriptor = FetchDescriptor<ItemModel>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        let models = try context.fetch(descriptor)
        return try await models.asyncMap { try await convertToDomain($0) }
    }

    func insert(_ item: Item, imageData: Data?) async throws {
        let context = ModelContext(container)

        // ID重複チェック（CloudKitは@Attribute(.unique)をサポートしないため手動チェック）
        let itemID = item.id
        let predicate = #Predicate<ItemModel> { $0.id == itemID }
        let descriptor = FetchDescriptor<ItemModel>(predicate: predicate)
        let existing = try context.fetch(descriptor)

        if !existing.isEmpty {
            // 既に存在する場合はupdateとして扱う
            print("⚠️ Item with ID \(item.id) already exists, updating instead")
            try await update(item, imageData: imageData)
            return
        }

        let now = Date()
        let model = ItemModel(
            id: item.id,
            coordinatesX: item.coordinates?.x.description,
            coordinatesY: item.coordinates?.y.description,
            coordinatesZ: item.coordinates?.z.description,
            worldID: item.world?.id,
            spotImageData: imageData,
            createdAt: item.createdAt,
            updatedAt: now
        )
        context.insert(model)
        try context.save()
    }

    func update(_ item: Item, imageData: Data?) async throws {
        let context = ModelContext(container)
        let itemID = item.id
        let predicate = #Predicate<ItemModel> { $0.id == itemID }
        let descriptor = FetchDescriptor<ItemModel>(predicate: predicate)

        guard let model = try context.fetch(descriptor).first else {
            throw NSError(domain: "ItemsSwiftDataSource", code: 404, userInfo: [NSLocalizedDescriptionKey: "Item not found"])
        }

        model.coordinatesX = item.coordinates?.x.description
        model.coordinatesY = item.coordinates?.y.description
        model.coordinatesZ = item.coordinates?.z.description
        model.worldID = item.world?.id
        if let imageData {
            model.spotImageData = imageData
        }
        model.updatedAt = Date()

        try context.save()
    }

    func delete(_ item: Item) async throws {
        let context = ModelContext(container)
        let itemID = item.id
        let predicate = #Predicate<ItemModel> { $0.id == itemID }
        let descriptor = FetchDescriptor<ItemModel>(predicate: predicate)

        guard let model = try context.fetch(descriptor).first else {
            return
        }

        context.delete(model)
        try context.save()
    }

    // MARK: - Private Methods

    private func convertToDomain(_ model: ItemModel) async throws -> Item {
        let coordinates: Coordinates?
        if let x = model.coordinatesX.flatMap(Int.init),
           let y = model.coordinatesY.flatMap(Int.init),
           let z = model.coordinatesZ.flatMap(Int.init)
        {
            coordinates = Coordinates(x: x, y: y, z: z)
        } else {
            coordinates = nil
        }

        var world: World?
        if let worldID = model.worldID {
            let worlds = try await worldsDataSource.fetchAll()
            world = worlds.first { $0.id == worldID }
        }

        return Item(
            id: model.id,
            coordinates: coordinates,
            world: world,
            spotImageName: model.spotImageData != nil ? model.id : nil,
            createdAt: model.createdAt,
            updatedAt: model.updatedAt
        )
    }
}
