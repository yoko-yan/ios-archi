//
//  ItemsLocalDataSource.swift
//
//
//  Created by takayuki.yokoda on 2023/07/01.
//

import Foundation

struct ItemsLocalDataSource: ItemsDataSource {
    private static let key = "ItemsDataStoreInStorage"

    func save(items: [Item]) {
        let entities = items.map { ItemEntity.translate($0) }
        guard let data = try? JSONEncoder().encode(entities) else { return }
        UserDefaults.standard.set(data, forKey: Self.key)
    }

    func load() -> [Item] {
        guard let data = UserDefaults.standard.object(forKey: Self.key) as? Data,
              let items = try? JSONDecoder().decode([ItemEntity].self, from: data)
        else { return [] }
        return items.sorted(by: { $0.createdAt > $1.createdAt }).map { Item.translate($0) }
    }
}
