//
//  Created by takayuki.yokoda on 2023/07/01.
//

import CoreData
import Foundation

struct ItemsLocalDataSource {
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

    private func getEntityById(_ id: UUID) async throws -> ItemEntity? {
        let request = ItemEntity.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(
            format: "id = %@", id.uuidString
        )
        let context = container.viewContext
        var itemEntity: ItemEntity?
        try await context.perform { [context] in
            itemEntity = try context.fetch(request)[0]
        }
        return itemEntity
    }

    func save(items: [Item]) async throws {
        // TODO:
        fatalError()
    }

    func load() async throws -> [Item] {
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

    func insert(item: Item) async throws {
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

    func update(item: Item) async throws {
        guard let id = UUID(uuidString: item.id),
              let itemEntity = try? await getEntityById(id)
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

    func delete(item: Item) async throws {
        guard let id = UUID(uuidString: item.id),
              let itemEntity = try? await getEntityById(id)
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

// import Foundation
// import CoreData
//
// struct ItemsLocalDataSource: ItemsDataSource {
//    private static let key = "ItemsDataStoreInStorage"
//
//    func save(items: [Item]) async throws {
//        guard let data = try? JSONEncoder().encode(items) else { fatalError() }
//        UserDefaults.standard.set(data, forKey: Self.key)
//    }
//
//    func load() async throws -> [Item] {
//        guard let data = UserDefaults.standard.object(forKey: Self.key) as? Data,
//              let items = try? JSONDecoder().decode([Item].self, from: data)
//        else { return [] }
//        return items.sorted(by: { $0.createdAt < $1.createdAt })
//    }
//
//    func insert(item: Item) async throws {
//        // TODO:
//        fatalError()
//    }
//
//    func update(item: Item) async throws {
//        var items = try await load()
//        if let index = items.firstIndex(where: { $0.id == item.id }) {
//            items[index] = item
//        } else {
//            items.append(item)
//        }
//        try await save(items: items)
//    }
//
//    func delete(item: Item) async throws {
//        // TODO:
//        fatalError()
//    }
// }
