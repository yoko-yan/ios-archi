//
//  Created by yoko-yan on 2023/10/11
//

import CoreData
import Foundation

protocol WorldsLocalDataSource {
    func getById(_ id: UUID) async throws -> World?
    func load() async throws -> [World]
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
    private let coreDataManager: CoreDataManager

    init(
        coreDataManager: some CoreDataManager = CoreDataManager.shared
    ) {
        self.coreDataManager = coreDataManager
    }

    private func getEntty(id: UUID) async throws -> WorldEntity? {
        let request = WorldEntity.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(
            format: "id = %@", id.uuidString
        )
        var entity: WorldEntity?
        try await coreDataManager.viewContext.perform { [context = coreDataManager.viewContext] in
            entity = try context.fetch(request).first
        }
        return entity
    }

    func getById(_ id: UUID) async throws -> World? {
        guard let entity = try await getEntty(id: id) else { return nil }
        return World(
            id: entity.id!.uuidString,
            name: entity.name,
            seed: Seed(entity.seed ?? ""),
            createdAt: entity.createdAt ?? Date(),
            updatedAt: entity.updatedAt ?? Date()
        )
    }

    func load() async throws -> [World] {
        let request = WorldEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \WorldEntity.createdAt, ascending: false)]
        guard let result = try? coreDataManager.viewContext.fetch(request)
        else { return [] }

        return result.map { entity in
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
        let entity = WorldEntity(context: coreDataManager.viewContext)
        entity.id = UUID(uuidString: world.id)
        entity.name = world.name
        entity.seed = world.seed?.text
        entity.createdAt = Date()
        entity.updatedAt = Date()
        CoreDataManager.shared.saveContext()
    }

    func update(_ world: World) async throws {
        guard let id = UUID(uuidString: world.id),
              let entity = try? await getEntty(id: id)
        else { throw ItemsLocalDataSourceError.updateFailed }
        entity.id = UUID(uuidString: world.id)
        entity.name = world.name
        entity.seed = world.seed?.text
        entity.createdAt = world.createdAt
        entity.updatedAt = Date()
        coreDataManager.saveContext()
    }

    func delete(_ world: World) async throws {
        guard let id = UUID(uuidString: world.id)
        else { throw ItemsLocalDataSourceError.deleteFailed }
        guard let entity = try? await getEntty(id: id)
        else { throw ItemsLocalDataSourceError.deleteFailed }
        coreDataManager.viewContext.delete(entity)
        try coreDataManager.viewContext.save()
    }
}
