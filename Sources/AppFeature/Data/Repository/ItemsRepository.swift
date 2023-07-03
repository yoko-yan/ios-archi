//
//  ItemsRepository.swift
//
//
//  Created by takayuki.yokoda on 2023/07/01.
//

import Foundation

final class ItemsRepository {
    let dataSource = ItemsDataSourceFactory.createItemsDataStore()

    func create(items: [Item]) {
        save(items: items)
    }

    func load() -> [Item] {
        dataSource.load()
    }

    func save(items: [Item]) {
        dataSource.save(items: items)
    }

    func update(item: Item) {
        dataSource.update(item: item)
    }
}

extension Item: Translator {
    static func translate(_ entity: ItemEntity) -> Self {
        let id = entity.id
        let coordinates = Coordinates.translate(entity.coordinates)
        let seed = Seed.translate(entity.seed)
        let coordinatesImageName = entity.coordinatesImageName
        let seedImageName = entity.seedImageName
        let createdAt = entity.createdAt
        let updatedAt = entity.updatedAt
        return Self(
            id: id,
            coordinates: coordinates,
            seed: seed,
            coordinatesImageName: coordinatesImageName,
            seedImageName: seedImageName,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

extension ItemEntity: Translator {
    static func translate(_ model: Item) -> Self {
        let id = model.id
        let coordinates = ItemEntity.Coordinates.translate(model.coordinates)
        let seed = ItemEntity.Seed.translate(model.seed)
        let coordinatesImageName = model.coordinatesImageName
        let seedImageName = model.seedImageName
        let createdAt = model.createdAt ?? Date()
        let updatedAt = model.updatedAt ?? Date()
        return Self(
            id: id,
            coordinates: coordinates,
            seed: seed,
            coordinatesImageName: coordinatesImageName,
            seedImageName: seedImageName,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

extension Coordinates: Translator {
    static func translate(_ entity: ItemEntity.Coordinates?) -> Self? {
        guard let entity else { return nil }
        return Self(x: entity.x, y: entity.y, z: entity.z)
    }
}

extension ItemEntity.Coordinates: Translator {
    static func translate(_ model: Coordinates?) -> Self? {
        guard let model else { return nil }
        return Self(x: model.x, y: model.y, z: model.z)
    }
}

extension Seed: Translator {
    static func translate(_ entity: ItemEntity.Seed?) -> Self? {
        guard let entity else { return nil }
        return Self(rawValue: entity.rawValue)
    }
}

extension ItemEntity.Seed: Translator {
    static func translate(_ model: Seed?) -> Self? {
        guard let model else { return nil }
        return Self(rawValue: model.rawValue)
    }
}
