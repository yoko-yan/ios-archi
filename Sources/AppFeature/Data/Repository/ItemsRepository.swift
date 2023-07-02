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

    func load() -> [Item] { dataSource.load().map { Item.translate($0) } }

    func save(items: [Item]) {
        let entities = items.map { ItemEntity(id: $0.id, seed: ItemEntity.Seed.translate($0.seed), coordinates: ItemEntity.Coordinates.translate($0.coordinates)) }
        dataSource.save(items: entities)
    }

    func update(item: Item) {
        var items = load()
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
        } else {
            items.append(item)
        }
        save(items: items)
    }
}
