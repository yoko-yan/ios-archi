//
//  Created by yoko-yan on 2023/10/11
//

import CoreData
import Foundation

struct WorldsLocalDataSource {
    private var context: NSManagedObjectContext {
        CoreDataManager.shared.viewContext
    }

    func getById(_ id: UUID) async throws -> World? {
        guard let entity = try await LocalDataSource<WorldEntity>.read(id: id)
        else { return nil }
        return World(
            id: entity.id!.uuidString,
            name: entity.name,
            seed: Seed(entity.seed ?? ""),
            createdAt: entity.createdAt ?? Date(),
            updatedAt: entity.updatedAt ?? Date()
        )
    }

    func save(worlds: [World]) async throws {
        // TODO:
        fatalError()
    }

    func load() async throws -> [World] {
        let request = WorldEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \WorldEntity.createdAt, ascending: false)]
        guard let result = try? context.fetch(request)
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

    func insert(world: World) async throws {
        let entity = WorldEntity(context: context)
        entity.id = UUID(uuidString: world.id)
        entity.name = world.name
        entity.seed = world.seed?.text
        entity.createdAt = Date()
        entity.updatedAt = Date()
        CoreDataManager.shared.saveContext()
    }

    func update(world: World) async throws {
        guard let id = UUID(uuidString: world.id),
              let entity = try? await LocalDataSource<WorldEntity>.read(id: id)
        else { fatalError() }
        entity.id = UUID(uuidString: world.id)
        entity.name = world.name
        entity.seed = world.seed?.text
        entity.createdAt = world.createdAt
        entity.updatedAt = Date()
        CoreDataManager.shared.saveContext()
    }

    func delete(world: World) async throws {
        guard let id = UUID(uuidString: world.id)
        else { fatalError() }
        try await LocalDataSource<WorldEntity>.delete(id: id)
    }
}
