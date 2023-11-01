//
//  Created by yoko-yan on 2023/10/11
//

import Foundation

final class WorldsRepository {
    private let dataSource: WorldsLocalDataSource

    init(dataSource: WorldsLocalDataSource = WorldsLocalDataSourceImpl()) {
        self.dataSource = dataSource
    }

    func fetchAll() async throws -> [World] {
        try await dataSource.fetchAll()
    }

    func insert(world: World) async throws {
        try await dataSource.insert(world)
    }

    func update(world: World) async throws {
        try await dataSource.update(world)
    }

    func delete(world: World) async throws {
        try await dataSource.delete(world)
    }
}
