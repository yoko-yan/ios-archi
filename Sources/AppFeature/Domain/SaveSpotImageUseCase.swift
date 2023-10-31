//
//  Created by yoko-yan on 2023/10/27
//

import Core
import Foundation
import UIKit

protocol SaveSpotImageUseCase {
    func execute(image: UIImage, fileName: String) async throws
}

struct SaveSpotImageUseCaseImpl: SaveSpotImageUseCase {
    @Injected(\.isCloudKitContainerAvailableUseCase) var isCloudKitContainerAvailable

    func execute(image: UIImage, fileName: String) async throws {
        if isCloudKitContainerAvailable.execute() {
            try await ICloudDocumentRepository().saveImage(image, fileName: fileName)
        }
        try await LocalImageRepository().saveImage(image, fileName: fileName)
    }
}
