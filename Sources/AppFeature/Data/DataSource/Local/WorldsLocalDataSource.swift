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

enum WorldsLocalDataSourceError: Error {
    case updateFailed
    case deleteFailed
}

final class WorldsLocalDataSourceImpl: WorldsLocalDataSource {
    private let localDataSource: LocalDataSource<WorldEntity>

    init(
        localDataSource: some LocalDataSource<WorldEntity> = LocalDataSource()
    ) {
        self.localDataSource = localDataSource
    }

    func getById(_ id: UUID) async throws -> World? {
        guard let entity = try? await localDataSource.read(id: id) else {
            throw WorldsLocalDataSourceError.updateFailed
        }
        return World(
            id: entity.id!.uuidString,
            name: entity.name,
            seed: Seed(entity.seed ?? ""),
            createdAt: entity.createdAt ?? Date(),
            updatedAt: entity.updatedAt ?? Date()
        )
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
            World(
                id: entity.id!.uuidString,
                name: entity.name,
                seed: Seed(entity.seed ?? ""),
                createdAt: entity.createdAt ?? Date(),
                updatedAt: entity.updatedAt ?? Date()
            )
        }
    }

    func insert(_ world: World) async throws {
        let entity = localDataSource.getEntity()
        entity.id = UUID(uuidString: world.id)
        entity.name = world.name
        entity.seed = world.seed?.text
        entity.createdAt = Date()
        entity.updatedAt = Date()
        try CoreDataManager.shared.saveContext()
    }

    func update(_ world: World) async throws {
        guard let id = UUID(uuidString: world.id),
              let entity = try? await localDataSource.read(id: id)
        else {
            throw WorldsLocalDataSourceError.updateFailed
        }
        entity.id = UUID(uuidString: world.id)
        entity.name = world.name
        entity.seed = world.seed?.text
        entity.createdAt = world.createdAt
        entity.updatedAt = Date()
        try localDataSource.saveContext()
    }

    func delete(_ world: World) async throws {
        guard let id = UUID(uuidString: world.id) else {
            throw ItemsLocalDataSourceError.deleteFailed
        }
        try await localDataSource.delete(id: id)
    }
}
