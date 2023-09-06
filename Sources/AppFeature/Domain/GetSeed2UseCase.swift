//
//  Created by yokoda.takayuki on 2023/07/27
//

import Combine
import Dependencies
import Foundation
import UIKit

protocol GetSeed2UseCase {
    func execute(image: UIImage) async throws -> Seed?
}

struct GetSeed2UseCaseImpl: GetSeed2UseCase {
    @Dependency(\.newRecognizedTextsRepository) var newRecognizedTextsRepository
    @Dependency(\.extractSeedUseCase) var extractSeedUseCase

    func execute(image: UIImage) async throws -> Seed? {
        let texts = try await newRecognizedTextsRepository.get(image: image)
        return await extractSeedUseCase.execute(texts: texts)
    }
}
