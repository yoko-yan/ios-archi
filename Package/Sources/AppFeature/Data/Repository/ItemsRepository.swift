import Dependencies
import Spyable
import UIKit

@Spyable
protocol ItemsRepository: Sendable {
    func fetchAll() async throws -> [Item]
    func fetchWithoutNoPhoto() async throws -> [Item]
    func insert(item: Item, image: UIImage?) async throws
    func update(item: Item, image: UIImage?) async throws
    func delete(item: Item) async throws
}

// MARK: - DependencyValues

private struct ItemsRepositoryKey: DependencyKey {
    @MainActor
    static let liveValue: any ItemsRepository = ItemsRepositoryImpl()
}

extension DependencyValues {
    var itemsRepository: any ItemsRepository {
        get { self[ItemsRepositoryKey.self] }
        set { self[ItemsRepositoryKey.self] = newValue }
    }
}

struct ItemsRepositoryImpl: ItemsRepository {
    private let dataSource: any ItemsSwiftDataSource

    @MainActor
    init(dataSource: some ItemsSwiftDataSource = ItemsSwiftDataSourceImpl()) {
        self.dataSource = dataSource
    }

    func fetchAll() async throws -> [Item] {
        try await dataSource.fetchAll()
    }

    func fetchWithoutNoPhoto() async throws -> [Item] {
        try await dataSource.fetchWithoutNoPhoto()
    }

    func insert(item: Item, image: UIImage?) async throws {
        let imageData = image?.jpegData(compressionQuality: 0.8)
        try await dataSource.insert(item, imageData: imageData)
    }

    func update(item: Item, image: UIImage?) async throws {
        let imageData = image?.jpegData(compressionQuality: 0.8)
        try await dataSource.update(item, imageData: imageData)
    }

    func delete(item: Item) async throws {
        try await dataSource.delete(item)
    }
}

#if DEBUG
extension ItemsRepositoryImpl {
    static var preview: some ItemsRepository {
        let repository = ItemsRepositoryMock()
        repository
            .fetchAllClosure = {
                [
                    Item.preview,
                    Item.previewWithImage,
                    Item.previewWithNoImage
                ]
            }
        return repository
    }
}
#endif
