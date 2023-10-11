//
//  Created by yokoda.takayuki on 2023/07/27
//

import Combine
import Foundation
import RegexBuilder
import UIKit

protocol GetSeedUseCase {
    func execute(image: UIImage) async throws -> Seed?
//    func execute(image: UIImage) -> AnyPublisher<Seed?, RecognizeTextLocalRequestError>
}

struct GetSeedUseCaseImpl: GetSeedUseCase {
    private let recognizedTextsRepository: RecognizedTextsRepository
    private let extractSeedUseCase: ExtractSeedUseCase

    init(
        recognizedTextsRepository: RecognizedTextsRepository = RecognizedTextsRepositoryImpl(),
        extractSeedUseCase: ExtractSeedUseCase = ExtractSeedUseCaseImpl()
    ) {
        self.recognizedTextsRepository = recognizedTextsRepository
        self.extractSeedUseCase = extractSeedUseCase
    }

    func execute(image: UIImage) async throws -> Seed? {
        let texts = try await recognizedTextsRepository.get(image: image)
        return await extractSeedUseCase.execute(texts: texts)
    }
}
