import Dependencies
import Macros
import UIKit

@Mockable
protocol LoadSpotImageUseCase: Sendable {
    func execute(fileName: String?) async throws -> UIImage?
}

// MARK: - DependencyValues

private struct LoadSpotImageUseCaseKey: DependencyKey {
    static let liveValue: any LoadSpotImageUseCase = LoadSpotImageUseCaseImpl()
}

extension DependencyValues {
    var loadSpotImageUseCase: any LoadSpotImageUseCase {
        get { self[LoadSpotImageUseCaseKey.self] }
        set { self[LoadSpotImageUseCaseKey.self] = newValue }
    }
}

struct LoadSpotImageUseCaseImpl: LoadSpotImageUseCase {
    @Dependency(\.isCloudKitContainerAvailableUseCase) private var isCloudKitContainerAvailableUseCase
    @Dependency(\.iCloudDocumentRepository) private var iCloudDocumentRepository
    @Dependency(\.localImageRepository) private var localImageRepository

    func execute(fileName: String?) async throws -> UIImage? {
        guard let fileName else { return nil }
        if isCloudKitContainerAvailableUseCase.execute() {
            let image = try await iCloudDocumentRepository.loadImage(fileName: fileName)
            if let image {
                try await localImageRepository.saveImage(image, fileName: fileName)
                return image
            } else {
                return try await localImageRepository.loadImage(fileName: fileName)
            }
        } else {
            return try await localImageRepository.loadImage(fileName: fileName)
        }
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
