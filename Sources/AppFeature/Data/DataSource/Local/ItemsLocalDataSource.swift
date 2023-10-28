//
//  Created by yoko-yan on 2023/07/01.
//

import CoreData
import Foundation

protocol ItemsLocalDataSource {
    func getAll() async throws -> [Item]
    func insert(_ item: Item) async throws
    func update(_ item: Item) async throws
    func delete(_ item: Item) async throws
}

final class ItemsLocalDataSourceImpl: ItemsLocalDataSource {
    private let coreDataManager: CoreDataManager
    private let worldsLocalDataSource: any WorldsLocalDataSource

    init(
        coreDataManager: some CoreDataManager = CoreDataManager.shared,
        worldsLocalDataSource: some WorldsLocalDataSource = WorldsLocalDataSourceImpl()
    ) {
        self.coreDataManager = coreDataManager
        self.worldsLocalDataSource = worldsLocalDataSource
    }

    private func getEntty(id: UUID) async throws -> ItemEntity? {
        let request = ItemEntity.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(
            format: "id = %@", id.uuidString
        )
        var entity: ItemEntity?
        try await coreDataManager.viewContext.perform { [context = coreDataManager.viewContext] in
            entity = try context.fetch(request).first
        }
        return entity
    }

    func getAll() async throws -> [Item] {
        let request = ItemEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ItemEntity.createdAt, ascending: false)]
        guard let result = try? coreDataManager.viewContext.fetch(request)
        else { return [] }

        var values = [Item]()
        for entity in result {
            let coordinates: Coordinates?
            if let entityCoordinatesX = entity.coordinatesX,
               let entityCoordinatesY = entity.coordinatesY,
               let entityCoordinatesZ = entity.coordinatesZ,
               let coordinatesX = Int(entityCoordinatesX),
               let coordinatesY = Int(entityCoordinatesY),
               let coordinatesZ = Int(entityCoordinatesZ)
            {
                coordinates = Coordinates(
                    x: coordinatesX,
                    y: coordinatesY,
                    z: coordinatesZ
                )
            } else {
                coordinates = nil
            }
            var world: World?
            if let worldId = entity.world {
                world = try await worldsLocalDataSource.getById(worldId)
            }
            values.append(
                Item(
                    id: entity.id!.uuidString,
                    coordinates: coordinates,
                    world: world,
                    spotImageName: entity.spotImageName,
                    createdAt: entity.createdAt ?? Date(),
                    updatedAt: entity.updatedAt ?? Date()
                )
            )
        }
        return values
    }

    func insert(_ item: Item) async throws {
        let entity = ItemEntity(context: coreDataManager.viewContext)
        entity.id = UUID(uuidString: item.id)
        if let coordinates = item.coordinates {
            entity.coordinatesX = String(coordinates.x)
            entity.coordinatesY = String(coordinates.y)
            entity.coordinatesZ = String(coordinates.z)
        }
        if let world = item.world {
            entity.world = UUID(uuidString: world.id)
        }
        entity.spotImageName = item.spotImageName
        entity.createdAt = Date()
        entity.updatedAt = Date()
        CoreDataManager.shared.saveContext()
    }

    func update(_ item: Item) async throws {
        guard let id = UUID(uuidString: item.id),
              let entity = try? await getEntty(id: id)
        else { fatalError() }
        entity.id = UUID(uuidString: item.id)
        if let coordinates = item.coordinates {
            entity.coordinatesX = String(coordinates.x)
            entity.coordinatesY = String(coordinates.y)
            entity.coordinatesZ = String(coordinates.z)
        }
        if let world = item.world {
            entity.world = UUID(uuidString: world.id)
        }
        entity.spotImageName = item.spotImageName
        entity.createdAt = item.createdAt
        entity.updatedAt = Date()
        coreDataManager.saveContext()
    }

    func delete(_ item: Item) async throws {
        guard let id = UUID(uuidString: item.id) else { fatalError() }
        guard let entity = try? await getEntty(id: id)
        else { fatalError() }
        coreDataManager.viewContext.delete(entity)
        try coreDataManager.viewContext.save()
    }
}
