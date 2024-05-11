import Core
import UIKit

protocol LoadSpotImageUseCase: AutoInjectable, AutoMockable {
    func execute(fileName: String?) async throws -> UIImage?
}

struct LoadSpotImageUseCaseImpl: LoadSpotImageUseCase {
    @Injected(\.isCloudKitContainerAvailableUseCase) var isCloudKitContainerAvailableUseCase
    @Injected(\.iCloudDocumentRepository) var iCloudDocumentRepository
    @Injected(\.localImageRepository) var localImageRepository

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
