//
//  Created by yoko-yan on 2023/10/27
//

import Core
import Foundation
import UIKit

protocol LoadSpotImageUseCase {
    func execute(fileName: String?) async throws -> UIImage?
}

struct LoadSpotImageUseCaseImpl: LoadSpotImageUseCase {
    @Injected(\.isCloudKitContainerAvailableUseCase) var isCloudKitContainerAvailable

    func execute(fileName: String?) async throws -> UIImage? {
        guard let fileName else { return nil }
        if isCloudKitContainerAvailable.execute() {
            let image = try await ICloudDocumentRepository().loadImage(fileName: fileName)
            if let image {
                try await LocalImageRepository().saveImage(image, fileName: fileName)
                return image
            } else {
                return try await LocalImageRepository().loadImage(fileName: fileName)
            }
        } else {
            return try await LocalImageRepository().loadImage(fileName: fileName)
        }
    }
}
