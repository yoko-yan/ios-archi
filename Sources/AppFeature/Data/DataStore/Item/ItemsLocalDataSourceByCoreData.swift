//
//  Created by takayuki.yokoda on 2023/07/03.
//

import CoreData
import Foundation

struct ItemsLocalDataSourceByCoreData: ItemsDataSource {
    let container: NSPersistentContainer

    init() {
        let modelURL = Bundle.module.url(forResource: "Model", withExtension: "momd")!
        let model = NSManagedObjectModel(contentsOf: modelURL)!
        container = NSPersistentCloudKitContainer(name: "Model", managedObjectModel: model)
        container.loadPersistentStores { _, error in
            if error != nil {
                fatalError("Cannot Load Core Data Model")
            }
        }
    }

    private func getEntityById(_ id: UUID) throws -> ItemEntity? {
        let request = ItemEntity.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(
            format: "id = %@", id.uuidString
        )
        let context = container.viewContext
        let itemEntity = try context.fetch(request)[0]
        return itemEntity
    }

    func save(items: [Item]) {
        // TODO:
        fatalError()
    }

    func load() -> [Item] {
        let request = ItemEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ItemEntity.createdAt, ascending: false)]
        guard let result = try? container.viewContext.fetch(request)
        else { fatalError() }

        return result.map { itemEntity in
            let coordinates: Coordinates?
            if let entityCoordinatesX = itemEntity.coordinatesX,
               let entityCoordinatesY = itemEntity.coordinatesY,
               let entityCoordinatesZ = itemEntity.coordinatesZ,
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
            let seed: Seed?
            if let entitySeedValue = itemEntity.seed,
               let seedValue = Int(entitySeedValue)
            {
                seed = Seed(rawValue: seedValue)
            } else {
                seed = nil
            }
            return Item(
                id: itemEntity.id!.uuidString,
                coordinates: coordinates,
                seed: seed,
                coordinatesImageName: itemEntity.coordinatesImageName,
                seedImageName: itemEntity.seedImageName,
                createdAt: itemEntity.createdAt ?? Date(),
                updatedAt: itemEntity.updatedAt ?? Date()
            )
        }
    }

    func insert(item: Item) {
        let itemEntity = ItemEntity(context: container.viewContext)
        itemEntity.id = UUID(uuidString: item.id)
        if let coordinates = item.coordinates {
            itemEntity.coordinatesX = String(coordinates.x)
            itemEntity.coordinatesY = String(coordinates.y)
            itemEntity.coordinatesZ = String(coordinates.z)
        }
        if let seed = item.seed?.rawValue {
            itemEntity.seed = String(seed)
        }
        itemEntity.coordinatesImageName = item.coordinatesImageName
        itemEntity.seedImageName = item.seedImageName
        itemEntity.createdAt = Date()
        itemEntity.updatedAt = Date()
        saveContext()
    }

    func update(item: Item) {
        guard let id = UUID(uuidString: item.id),
              let itemEntity = try? getEntityById(id)
        else { fatalError() }
        itemEntity.id = UUID(uuidString: item.id)
        if let coordinates = item.coordinates {
            itemEntity.coordinatesX = String(coordinates.x)
            itemEntity.coordinatesY = String(coordinates.y)
            itemEntity.coordinatesZ = String(coordinates.z)
        }
        if let seed = item.seed?.rawValue {
            itemEntity.seed = String(seed)
        }
        itemEntity.coordinatesImageName = item.coordinatesImageName
        itemEntity.seedImageName = item.seedImageName
        itemEntity.createdAt = item.createdAt
        itemEntity.updatedAt = Date()
        saveContext()
    }

    func delete(item: Item) {
        guard let id = UUID(uuidString: item.id),
              let itemEntity = try? getEntityById(id)
        else { fatalError() }
        let context = container.viewContext
        context.delete(itemEntity)
        do {
            try context.save()
        } catch {
            context.rollback()
            fatalError("Error: \(error.localizedDescription)")
        }
    }

    private func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
    }
}
