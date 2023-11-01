//
//  Created by yoko-yan on 2023/07/01.
//

import CoreData
import Foundation

protocol ItemsLocalDataSource {
    func fetchAll() async throws -> [Item]
    func insert(_ item: Item) async throws
    func update(_ item: Item) async throws
    func delete(_ item: Item) async throws
}

// MARK: - Error

final class ItemsLocalDataSourceImpl: ItemsLocalDataSource {
    private let localDataSource: LocalDataSource<ItemEntity>
    private let worldsLocalDataSource: any WorldsLocalDataSource

    init(
        //        localDataSource: some LocalDataSource = LocalDataSourceImpl<ItemEntity>(),
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

    private func fetch(_ sortDescriptors: [NSSortDescriptor]) async throws -> [Item] {
        let sortDescriptors = [
            NSSortDescriptor(
                keyPath: \ItemEntity.createdAt,
                ascending: false
            )
        ]
        let entities = try await localDataSource.fetch(sortDescriptors)
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
        return try await fetch(sortDescriptors)
    }

    func fetchWith() async throws -> [Item] {
        let sortDescriptors = [
            NSSortDescriptor(
                keyPath: \ItemEntity.createdAt,
                ascending: false
            )
        ]
        return try await fetch(sortDescriptors)
    }

    func insert(_ item: Item) async throws {
        let entity = localDataSource.getEntity()
        entity.id = UUID(uuidString: item.id)
        let changedEntity = setEntity(entity: entity, from: item)
        changedEntity.createdAt = Date()
        changedEntity.updatedAt = Date()
        try localDataSource.saveContext()
    }

    func update(_ item: Item) async throws {
        guard let id = UUID(uuidString: item.id) else {
            fatalError("Failed to convert to UUID.")
        }
        guard let entity = try? await localDataSource.read(id: id) else {
            fatalError("There was no matching data.")
        }
        let changedEntity = setEntity(entity: entity, from: item)
        changedEntity.createdAt = item.createdAt
        changedEntity.updatedAt = Date()
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
            id: entity.id!.uuidString,
            coordinates: coordinates,
            world: world,
            spotImageName: entity.spotImageName,
            createdAt: entity.createdAt ?? Date(),
            updatedAt: entity.updatedAt ?? Date()
        )
    }
}
