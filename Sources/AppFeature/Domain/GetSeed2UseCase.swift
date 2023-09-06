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
    @Dependency(\.makeSeedUseCase) var makeSeedUseCase

    func execute(image: UIImage) async throws -> Seed? {
        let texts = try await newRecognizedTextsRepository.get(image: image)
        // シード値に余計な文字がついてしまったケースを考慮し、読み取れた文字を１つの文字列にして、シード値の形式にマッチするものをSeedにする
        let text = texts.joined(separator: " ")
        return await makeSeedUseCase.execute(text: text)
    }
}
