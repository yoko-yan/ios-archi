//
//  Created by takayuki.yokoda on 2023/07/01.
//

import Foundation

final class ItemRepository {
    private let dataSource: ItemsLocalDataSource
    init(dataSource: ItemsLocalDataSource = ItemsLocalDataSource()) {
        self.dataSource = dataSource
    }

    func create(items: [Item]) async throws {
        try await save(items: items)
    }

    func load() async throws -> [Item] {
        try await dataSource.load()
    }

    func save(items: [Item]) async throws {
        try await dataSource.save(items: items)
    }

    func insert(item: Item) async throws {
        try await dataSource.insert(item: item)
    }

    func update(item: Item) async throws {
        try await dataSource.update(item: item)
    }

    func delete(item: Item) async throws {
        try await dataSource.delete(item: item)
    }
}
