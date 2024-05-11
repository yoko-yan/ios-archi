import CoreData

protocol WorldsLocalDataSource {
    func getById(_ id: UUID) async throws -> World?
    func fetchAll() async throws -> [World]
    func insert(_ world: World) async throws
    func update(_ world: World) async throws
    func delete(_ world: World) async throws
}

final class WorldsLocalDataSourceImpl: WorldsLocalDataSource {
    private let localDataSource: LocalDataSource<WorldEntity>

    init(
        localDataSource: LocalDataSource<WorldEntity> = LocalDataSource()
    ) {
        self.localDataSource = localDataSource
    }

    func getById(_ id: UUID) async throws -> World? {
        guard let entity = try await localDataSource.read(id: id) else { return nil }
        return convertToItem(from: entity)
    }

    func fetchAll() async throws -> [World] {
        let sortDescriptors = [
            NSSortDescriptor(
                keyPath: \ItemEntity.createdAt,
                ascending: false
            )
        ]
        let entities = try await localDataSource.fetch(predicate: nil, sortDescriptors: sortDescriptors)

        return entities.map { entity in
            convertToItem(from: entity)
        }
    }

    func insert(_ world: World) async throws {
        let entity = localDataSource.getEntity()
        let ent = setEntity(entity: entity, from: world)
        ent.createdAt = Date()
        ent.updatedAt = Date()
        try CoreDataManager.shared.saveContext()
    }

    func update(_ world: World) async throws {
        guard let id = UUID(uuidString: world.id) else {
            fatalError("Failed to convert to UUID.")
        }
        guard let entity = try? await localDataSource.read(id: id) else {
            fatalError("There was no matching data.")
        }
        let ent = setEntity(entity: entity, from: world)
        ent.createdAt = world.createdAt
        ent.updatedAt = Date()
        try localDataSource.saveContext()
    }

    func delete(_ world: World) async throws {
        guard let id = UUID(uuidString: world.id) else {
            fatalError("Failed to convert to UUID.")
        }
        try await localDataSource.delete(id: id)
    }
}

private extension WorldsLocalDataSourceImpl {
    func setEntity(entity: WorldEntity, from world: World) -> WorldEntity {
        entity.id = UUID(uuidString: world.id)
        entity.name = world.name
        entity.seed = world.seed?.text
        entity.createdAt = world.createdAt
        entity.updatedAt = Date()
        return entity
    }

    func convertToItem(from entity: WorldEntity) -> World {
        guard let id = entity.id else { fatalError("WorldEntity: id not found") }
        return World(
            id: id.uuidString,
            name: entity.name,
            seed: Seed(entity.seed ?? ""),
            createdAt: entity.createdAt ?? Date(),
            updatedAt: entity.updatedAt ?? Date()
        )
    }
}
