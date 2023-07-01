//
//  ItemsDataStoreInStorage.swift
//
//
//  Created by takayuki.yokoda on 2023/07/01.
//

import Foundation

struct ItemsDataStoreInStorage: ItemsDataStore {
    private static let key = "ItemsDataStoreInStorage"

    func save(items: [ItemEntity]) {
        guard let data = try? JSONEncoder().encode(items) else { return }
        UserDefaults.standard.set(data, forKey: Self.key)
    }

    func load() -> [ItemEntity] {
        guard let data = UserDefaults.standard.object(forKey: Self.key) as? Data,
              let items = try? JSONDecoder().decode([ItemEntity].self, from: data)
        else { return [] }
        return items
    }
}
