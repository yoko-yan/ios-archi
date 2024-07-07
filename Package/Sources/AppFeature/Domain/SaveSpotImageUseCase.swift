import Core
import UIKit

protocol SaveSpotImageUseCase: Sendable {
    func execute(image: UIImage, fileName: String) async throws
}

struct SaveSpotImageUseCaseImpl: SaveSpotImageUseCase {
    @Injected(\.isCloudKitContainerAvailableUseCase) private var isCloudKitContainerAvailableUseCase
    @Injected(\.iCloudDocumentRepository) private var iCloudDocumentRepository
    @Injected(\.localImageRepository) private var localImageRepository

    func execute(image: UIImage, fileName: String) async throws {
        if isCloudKitContainerAvailableUseCase.execute() {
            try await iCloudDocumentRepository.saveImage(image, fileName: fileName)
        }
        try await localImageRepository.saveImage(image, fileName: fileName)
    }
}
