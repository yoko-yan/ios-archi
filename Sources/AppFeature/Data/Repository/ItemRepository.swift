//
//  ItemRepository.swift
//
//
//  Created by takayuki.yokoda on 2023/07/01.
//

import Foundation

final class ItemRepository {
    let dataSource = ItemsDataSourceFactory.createItemsDataStore()

    func create(items: [Item]) {
        save(items: items)
    }

    func load() -> [Item] {
        do {
            return try dataSource.load()
        } catch {
            fatalError("")
        }
    }

    func save(items: [Item]) {
        do {
            try dataSource.save(items: items)
        } catch {
            print(error)
        }
    }

    func insert(item: Item) {
        do {
            try dataSource.insert(item: item)
        } catch {
            print(error)
        }
    }

    func update(item: Item) {
        do {
            try dataSource.update(item: item)
        } catch {
            print(error)
        }
    }
}
