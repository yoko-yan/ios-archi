//
//  Created by yoko-yan on 2023/07/01.
//

import CoreData
import Foundation

struct ItemsLocalDataSource {
    private var context: NSManagedObjectContext {
        CoreDataManager.shared.viewContext
    }

    func getAll() async throws -> [Item] {
        let request = ItemEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ItemEntity.createdAt, ascending: false)]
        guard let result = try? context.fetch(request)
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
                world = try await WorldsLocalDataSource().getById(worldId)
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

    func insert(item: Item) async throws {
        let entity = ItemEntity(context: context)
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

    func update(item: Item) async throws {
        guard let id = UUID(uuidString: item.id),
              let entity = try? await LocalDataSource<ItemEntity>.read(id: id)
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
        CoreDataManager.shared.saveContext()
    }

    func delete(item: Item) async throws {
        guard let id = UUID(uuidString: item.id)
        else { fatalError() }
        try await LocalDataSource<ItemEntity>.delete(id: id)
    }
}
