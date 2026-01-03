import Dependencies
import Spyable

@Spyable
protocol WorldsRepositoryProtocol: Sendable {
    func fetchAll() async throws -> [World]
    func insert(world: World) async throws
    func update(world: World) async throws
    func delete(world: World) async throws
}

// MARK: - DependencyValues

private struct WorldsRepositoryKey: DependencyKey {
    @MainActor
    static let liveValue: any WorldsRepositoryProtocol = WorldsRepository()
}

extension DependencyValues {
    var worldsRepository: any WorldsRepositoryProtocol {
        get { self[WorldsRepositoryKey.self] }
        set { self[WorldsRepositoryKey.self] = newValue }
    }
}

final class WorldsRepository: WorldsRepositoryProtocol {
    private let dataSource: any WorldsSwiftDataSource

    @MainActor
    init(dataSource: some WorldsSwiftDataSource = WorldsSwiftDataSourceImpl()) {
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
