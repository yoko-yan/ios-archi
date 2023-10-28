//
//  Created by yoko-yan on 2023/07/01.
//

import Foundation

final class ItemsRepository {
    private let dataSource: ItemsLocalDataSource

    init(dataSource: some ItemsLocalDataSource = ItemsLocalDataSourceImpl()) {
        self.dataSource = dataSource
    }

    func getAll() async throws -> [Item] {
        try await dataSource.getAll()
    }

    func insert(item: Item) async throws {
        try await dataSource.insert(item)
    }

    func update(item: Item) async throws {
        try await dataSource.update(item)
    }

    func delete(item: Item) async throws {
        try await dataSource.delete(item)
    }
}
