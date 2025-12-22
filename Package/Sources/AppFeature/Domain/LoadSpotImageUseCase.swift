import Dependencies
import Foundation
import Macros
import SwiftData
import UIKit

@Mockable
protocol LoadSpotImageUseCase: Sendable {
    func execute(fileName: String?) async throws -> UIImage?
}

// MARK: - DependencyValues

private struct LoadSpotImageUseCaseKey: DependencyKey {
    @MainActor
    static let liveValue: any LoadSpotImageUseCase = LoadSpotImageUseCaseImpl()
}

extension DependencyValues {
    var loadSpotImageUseCase: any LoadSpotImageUseCase {
        get { self[LoadSpotImageUseCaseKey.self] }
        set { self[LoadSpotImageUseCaseKey.self] = newValue }
    }
}

@MainActor
struct LoadSpotImageUseCaseImpl: LoadSpotImageUseCase {
    func execute(fileName: String?) async throws -> UIImage? {
        guard let fileName else { return nil }

        // SwiftDataから画像を読み込む
        let container = SwiftDataManager.shared.container
        let context = ModelContext(container)

        let predicate = #Predicate<ItemModel> { $0.id == fileName }
        let descriptor = FetchDescriptor<ItemModel>(predicate: predicate)

        guard let model = try context.fetch(descriptor).first,
              let imageData = model.spotImageData else {
            return nil
        }

        return UIImage(data: imageData)
    }
}

#if DEBUG
extension LoadSpotImageUseCaseImpl {
    static var preview: some LoadSpotImageUseCase {
        let repository = LoadSpotImageUseCaseMock()
        repository
            .executeFileNameClosure = { _ in
                UIImage(resource: .sampleCoordinates)
            }
        return repository
    }
}
#endif
