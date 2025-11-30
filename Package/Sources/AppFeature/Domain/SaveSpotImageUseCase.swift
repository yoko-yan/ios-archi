import Dependencies
import UIKit

protocol SaveSpotImageUseCase: Sendable {
    func execute(image: UIImage, fileName: String) async throws
}

struct SaveSpotImageUseCaseImpl: SaveSpotImageUseCase {
    @Dependency(\.isCloudKitContainerAvailableUseCase) private var isCloudKitContainerAvailableUseCase
    @Dependency(\.iCloudDocumentRepository) private var iCloudDocumentRepository
    @Dependency(\.localImageRepository) private var localImageRepository

    func execute(image: UIImage, fileName: String) async throws {
        if isCloudKitContainerAvailableUseCase.execute() {
            try await iCloudDocumentRepository.saveImage(image, fileName: fileName)
        }
        try await localImageRepository.saveImage(image, fileName: fileName)
    }
}
