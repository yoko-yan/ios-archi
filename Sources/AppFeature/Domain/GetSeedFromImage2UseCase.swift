//
//  Created by yokoda.takayuki on 2023/07/27
//

import Combine
import Dependencies
import Foundation
import UIKit

protocol GetSeedFromImage2UseCase {
    func execute(image: UIImage) async throws -> Seed?
}

struct GetSeedFromImage2UseCaseImpl: GetSeedFromImage2UseCase {
    @Dependency(\.newRecognizedTextsRepository) var newRecognizedTextsRepository
    @Dependency(\.getSeedFromTextUseCase) var getSeedFromTextUseCase

    func execute(image: UIImage) async throws -> Seed? {
        let texts = try await newRecognizedTextsRepository.get(image: image)
        return await getSeedFromTextUseCase.execute(texts: texts)
    }
}
