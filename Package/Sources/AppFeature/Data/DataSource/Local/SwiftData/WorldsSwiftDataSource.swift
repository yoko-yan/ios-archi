import Foundation
import SwiftData

protocol WorldsSwiftDataSource: Sendable {
    func fetchAll() async throws -> [World]
    func insert(_ world: World) async throws
    func update(_ world: World) async throws
    func delete(_ world: World) async throws
}

@MainActor
final class WorldsSwiftDataSourceImpl: WorldsSwiftDataSource {
    private let container: ModelContainer

    init(container: ModelContainer = SwiftDataManager.shared.container) {
        self.container = container
    }

    func fetchAll() async throws -> [World] {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<WorldModel>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        let models = try context.fetch(descriptor)
        print("📊 WorldsSwiftDataSource.fetchAll: fetched \(models.count) worlds")
        if models.isEmpty {
            print("⚠️ No worlds found in local store")
        } else {
            print("ℹ️ World IDs: \(models.map { $0.id }.prefix(5))")
        }
        return models.map(convertToDomain)
    }

    func insert(_ world: World) async throws {
        let context = ModelContext(container)

        // ID重複チェック（CloudKitは@Attribute(.unique)をサポートしないため手動チェック）
        let worldID = world.id
        let predicate = #Predicate<WorldModel> { $0.id == worldID }
        let descriptor = FetchDescriptor<WorldModel>(predicate: predicate)
        let existing = try context.fetch(descriptor)

        if !existing.isEmpty {
            // 既に存在する場合はupdateとして扱う
            print("⚠️ World with ID \(world.id) already exists, updating instead")
            try await update(world)
            return
        }

        let now = Date()
        let model = WorldModel(
            id: world.id,
            name: world.name,
            seed: world.seed?.rawValue.description,
            createdAt: world.createdAt,
            updatedAt: now
        )
        context.insert(model)
        try context.save()
    }

    func update(_ world: World) async throws {
        let context = ModelContext(container)
        let worldID = world.id
        let predicate = #Predicate<WorldModel> { $0.id == worldID }
        let descriptor = FetchDescriptor<WorldModel>(predicate: predicate)

        guard let model = try context.fetch(descriptor).first else {
            throw NSError(domain: "WorldsSwiftDataSource", code: 404, userInfo: [NSLocalizedDescriptionKey: "World not found"])
        }

        model.name = world.name
        model.seed = world.seed?.rawValue.description
        model.updatedAt = Date()

        try context.save()
    }

    func delete(_ world: World) async throws {
        let context = ModelContext(container)
        let worldID = world.id
        let predicate = #Predicate<WorldModel> { $0.id == worldID }
        let descriptor = FetchDescriptor<WorldModel>(predicate: predicate)

        guard let model = try context.fetch(descriptor).first else {
            return
        }

        context.delete(model)
        try context.save()
    }

    // MARK: - Private Methods

    private func convertToDomain(_ model: WorldModel) -> World {
        World(
            id: model.id,
            name: model.name,
            seed: model.seed.flatMap { Int($0) }.flatMap { Seed(rawValue: $0) },
            createdAt: model.createdAt,
            updatedAt: model.updatedAt
        )
    }
}
