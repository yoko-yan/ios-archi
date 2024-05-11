import Core
import UIKit

protocol SaveSpotImageUseCase {
    func execute(image: UIImage, fileName: String) async throws
}

struct SaveSpotImageUseCaseImpl: SaveSpotImageUseCase {
    @Injected(\.isCloudKitContainerAvailableUseCase) var isCloudKitContainerAvailableUseCase
    @Injected(\.iCloudDocumentRepository) var iCloudDocumentRepository
    @Injected(\.localImageRepository) var localImageRepository

    func execute(image: UIImage, fileName: String) async throws {
        if isCloudKitContainerAvailableUseCase.execute() {
            try await iCloudDocumentRepository.saveImage(image, fileName: fileName)
        }
        try await localImageRepository.saveImage(image, fileName: fileName)
    }
}
