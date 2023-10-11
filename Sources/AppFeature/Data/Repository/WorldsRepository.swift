//
//  Created by takayuki.yokoda on 2023/10/11
//

import Foundation

final class WorldsRepository {
    private let dataSource: WorldsLocalDataSource

    init(dataSource: WorldsLocalDataSource = WorldsLocalDataSource()) {
        self.dataSource = dataSource
    }

    func create(worlds: [World]) async throws {
        try await save(worlds: worlds)
    }

    func load() async throws -> [World] {
        try await dataSource.load()
    }

    func save(worlds: [World]) async throws {
        try await dataSource.save(worlds: worlds)
    }

    func insert(world: World) async throws {
        try await dataSource.insert(world: world)
    }

    func update(world: World) async throws {
        try await dataSource.update(world: world)
    }

    func delete(world: World) async throws {
        try await dataSource.delete(world: world)
    }
}
