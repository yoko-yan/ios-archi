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
    private let makeSeedUseCase: MakeSeedUseCase
    init(
        recognizedTextsRepository: RecognizedTextsRepository = RecognizedTextsRepositoryImpl(),
        makeSeedUseCase: MakeSeedUseCase = MakeSeedUseCaseImpl()
    ) {
        self.recognizedTextsRepository = recognizedTextsRepository
        self.makeSeedUseCase = makeSeedUseCase
    }

    func execute(image: UIImage) async throws -> Seed? {
        let texts = try await recognizedTextsRepository.get(image: image)
        // シード値に余計な文字がついてしまったケースを考慮し、読み取れた文字を１つの文字列にして、シード値の形式にマッチするものをSeedにする
        let text = texts.joined(separator: " ")
        return await makeSeedUseCase.execute(text: text)
    }
}
