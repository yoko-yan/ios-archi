//
//  Created by yokoda.takayuki on 2023/07/27
//

import Combine
import Foundation
import RegexBuilder
import UIKit

protocol GetSeedFromImageUseCase {
    func execute(image: UIImage) async throws -> Seed?
//    func execute(image: UIImage) -> AnyPublisher<Seed?, RecognizeTextLocalRequestError>
}

struct GetSeedFromImageUseCaseImpl: GetSeedFromImageUseCase {
    private let recognizedTextsRepository: RecognizedTextsRepository
    private let getSeedFromTextUseCase: GetSeedFromTextUseCase

    init(
        recognizedTextsRepository: RecognizedTextsRepository = RecognizedTextsRepositoryImpl(),
        getSeedFromTextUseCase: GetSeedFromTextUseCase = GetSeedFromTextUseCaseImpl()
    ) {
        self.recognizedTextsRepository = recognizedTextsRepository
        self.getSeedFromTextUseCase = getSeedFromTextUseCase
    }

    func execute(image: UIImage) async throws -> Seed? {
        let texts = try await recognizedTextsRepository.get(image: image)
        return await getSeedFromTextUseCase.execute(texts: texts)
    }
}
