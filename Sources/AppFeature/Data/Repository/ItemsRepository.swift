//
//  Created by yoko-yan on 2023/07/01.
//

import Core
import Foundation

protocol ItemsRepository: AutoInjectable {
    func fetchAll() async throws -> [Item]
    func fetchWithoutNoPhoto() async throws -> [Item]
    func insert(item: Item) async throws
    func update(item: Item) async throws
    func delete(item: Item) async throws
}

struct ItemsRepositoryImpl: ItemsRepository {
    private let dataSource: ItemsLocalDataSource

    init(dataSource: some ItemsLocalDataSource = ItemsLocalDataSourceImpl()) {
        self.dataSource = dataSource
    }

    func fetchAll() async throws -> [Item] {
        try await dataSource.fetchAll()
    }

    func fetchWithoutNoPhoto() async throws -> [Item] {
        try await dataSource.fetchWithoutNoPhoto()
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
