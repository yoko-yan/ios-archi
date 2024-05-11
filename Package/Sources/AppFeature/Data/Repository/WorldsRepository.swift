final class WorldsRepository {
    private let dataSource: any WorldsLocalDataSource

    init(dataSource: any WorldsLocalDataSource = WorldsLocalDataSourceImpl()) {
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
