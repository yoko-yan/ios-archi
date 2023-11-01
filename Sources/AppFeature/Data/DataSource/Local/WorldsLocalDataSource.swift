//
//  Created by yoko-yan on 2023/10/11
//

import CoreData
import Foundation

protocol WorldsLocalDataSource {
    func getById(_ id: UUID) async throws -> World?
    func fetchAll() async throws -> [World]
    func insert(_ world: World) async throws
    func update(_ world: World) async throws
    func delete(_ world: World) async throws
}

// MARK: - Error

final class WorldsLocalDataSourceImpl: WorldsLocalDataSource {
    private let localDataSource: LocalDataSource<WorldEntity>

    init(
        //        localDataSource: some LocalDataSource = LocalDataSourceImpl<WorldEntity>()
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
        let entities = try await localDataSource.fetch(sortDescriptors)

        return entities.map { entity in
            convertToItem(from: entity)
        }
    }

    func insert(_ world: World) async throws {
        let entity = localDataSource.getEntity()
        let changedEntity = setEntity(entity: entity, from: world)
        changedEntity.createdAt = Date()
        changedEntity.updatedAt = Date()
        try CoreDataManager.shared.saveContext()
    }

    func update(_ world: World) async throws {
        guard let id = UUID(uuidString: world.id) else {
            fatalError("Failed to convert to UUID.")
        }
        guard let entity = try? await localDataSource.read(id: id) else {
            fatalError("There was no matching data.")
        }
        let changedEntity = setEntity(entity: entity, from: world)
        entity.createdAt = world.createdAt
        entity.updatedAt = Date()
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
        World(
            id: entity.id!.uuidString,
            name: entity.name,
            seed: Seed(entity.seed ?? ""),
            createdAt: entity.createdAt ?? Date(),
            updatedAt: entity.updatedAt ?? Date()
        )
    }
}
