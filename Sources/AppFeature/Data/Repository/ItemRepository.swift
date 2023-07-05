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
        dataSource.load()
    }

    func save(items: [Item]) {
        dataSource.save(items: items)
    }

    func insert(item: Item) {
        dataSource.insert(item: item)
    }

    func update(item: Item) {
        dataSource.update(item: item)
    }

    func delete(item: Item) {
        dataSource.delete(item: item)
    }
}
