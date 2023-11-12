//
//  Created by yoko-yan on 2023/07/01.
//

import CoreData
import Foundation

protocol ItemsLocalDataSource {
    func fetchAll() async throws -> [Item]
    func fetchWithoutNoPhoto() async throws -> [Item]
    func insert(_ item: Item) async throws
    func update(_ item: Item) async throws
    func delete(_ item: Item) async throws
}

final class ItemsLocalDataSourceImpl: ItemsLocalDataSource {
    private let localDataSource: LocalDataSource<ItemEntity>
    private let worldsLocalDataSource: any WorldsLocalDataSource

    init(
        localDataSource: LocalDataSource<ItemEntity> = LocalDataSource(),
        worldsLocalDataSource: some WorldsLocalDataSource = WorldsLocalDataSourceImpl()
    ) {
        self.localDataSource = localDataSource
        self.worldsLocalDataSource = worldsLocalDataSource
    }

    func getById(_ id: UUID) async throws -> Item? {
        guard let entity = try await localDataSource.read(id: id) else { return nil }
        return try await convertToItem(from: entity)
    }

    private func fetch(predicate: NSPredicate? = nil, sortDescriptors lSortDescriptors: [NSSortDescriptor]? = nil) async throws -> [Item] {
        let sortDescriptors: [NSSortDescriptor]?
        if let lSortDescriptors {
            sortDescriptors = lSortDescriptors
        } else {
            sortDescriptors = [
                NSSortDescriptor(
                    keyPath: \ItemEntity.createdAt,
                    ascending: false
                )
            ]
        }

        let entities = try await localDataSource.fetch(predicate: predicate, sortDescriptors: sortDescriptors)
        var values = [Item]()
        for entity in entities {
            try await values.append(
                convertToItem(from: entity)
            )
        }
        return values
    }

    func fetchAll() async throws -> [Item] {
        let sortDescriptors = [
            NSSortDescriptor(
                keyPath: \ItemEntity.createdAt,
                ascending: false
            )
        ]
        return try await fetch(predicate: nil, sortDescriptors: sortDescriptors)
    }

    func fetchWithoutNoPhoto() async throws -> [Item] {
        let predicate = NSPredicate(format: "spotImageName != nil OR spotImageName == %@", "")
        let sortDescriptors = [
            NSSortDescriptor(
                keyPath: \ItemEntity.createdAt,
                ascending: false
            )
        ]
        return try await fetch(predicate: predicate, sortDescriptors: sortDescriptors)
    }

    func insert(_ item: Item) async throws {
        let entity = localDataSource.getEntity()
        entity.id = UUID(uuidString: item.id)
        let ent = setEntity(entity: entity, from: item)
        ent.createdAt = Date()
        ent.updatedAt = Date()
        try localDataSource.saveContext()
    }

    func update(_ item: Item) async throws {
        guard let id = UUID(uuidString: item.id) else {
            fatalError("Failed to convert to UUID.")
        }
        guard let entity = try? await localDataSource.read(id: id) else {
            fatalError("There was no matching data.")
        }
        let ent = setEntity(entity: entity, from: item)
        ent.createdAt = item.createdAt
        ent.updatedAt = Date()
        try localDataSource.saveContext()
    }

    func delete(_ item: Item) async throws {
        guard let id = UUID(uuidString: item.id) else {
            fatalError("Failed to convert to UUID.")
        }
        try await localDataSource.delete(id: id)
    }
}

private extension ItemsLocalDataSourceImpl {
    func setEntity(entity: ItemEntity, from item: Item) -> ItemEntity {
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
        entity.updatedAt = item.updatedAt
        return entity
    }

    func convertToItem(from entity: ItemEntity) async throws -> Item {
        guard let id = entity.id else { fatalError("ItemEntity: id not found") }
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
        return Item(
            id: id.uuidString,
            coordinates: coordinates,
            world: world,
            spotImageName: entity.spotImageName,
            createdAt: entity.createdAt ?? Date(),
            updatedAt: entity.updatedAt ?? Date()
        )
    }
}
