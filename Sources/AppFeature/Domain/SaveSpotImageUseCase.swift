//
//  Created by apla on 2023/10/27
//

import Foundation
import UIKit

protocol SaveSpotImageUseCase {
    func execute(image: UIImage, fileName: String) async throws
}

struct SaveSpotImageUseCaseImpl: SaveSpotImageUseCase {
    private let isiCloudUseCase: IsiCloudUseCase

    init(
        isiCloudUseCase: IsiCloudUseCase = IsiCloudUseCaseImpl()
    ) {
        self.isiCloudUseCase = isiCloudUseCase
    }

    func execute(image: UIImage, fileName: String) async throws {
        if isiCloudUseCase.execute() {
            try await ICloudDocumentRepository().saveImage(image, fileName: fileName)
        }
        try await LocalImageRepository().saveImage(image, fileName: fileName)
    }
}
