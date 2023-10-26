//
//  Created by apla on 2023/10/27
//

import Foundation
import UIKit

protocol LoadSpotImageUseCase {
    func execute(fileName: String?) async throws -> UIImage?
}

struct LoadSpotImageUseCaseImpl: LoadSpotImageUseCase {
    private let isiCloudUseCase: IsiCloudUseCase

    init(
        isiCloudUseCase: IsiCloudUseCase = IsiCloudUseCaseImpl()
    ) {
        self.isiCloudUseCase = isiCloudUseCase
    }

    func execute(fileName: String?) async throws -> UIImage? {
        guard let fileName else { return nil }
        if isiCloudUseCase.execute() {
            let image = try await ICloudDocumentRepository().loadImage(fileName: fileName)
            if let image {
                try await LocalImageRepository().saveImage(image, fileName: fileName)
            }
            return image
        } else {
            return try await LocalImageRepository().loadImage(fileName: fileName)
        }
    }
}
