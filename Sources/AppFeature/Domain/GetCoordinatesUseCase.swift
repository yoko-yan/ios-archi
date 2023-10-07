//
//  Created by yokoda.takayuki on 2023/07/27
//

import Combine
import Foundation
import RegexBuilder
import UIKit

struct GetCoordinatesUseCaseImpl {
    private let recognizeTextRepository: RecognizedTextsRepository
    init(recognizeTextRepository: RecognizedTextsRepository = RecognizedTextsRepositoryImpl()) {
        self.recognizeTextRepository = recognizeTextRepository
    }

    func execute(image: UIImage) async throws -> Coordinates? {
        let texts = try await recognizeTextRepository.get(image: image)
        // 座標が分割して認識されてしまったケースを考慮し、読み取れた文字を１つの文字列にして、座標の形式にマッチするものをCoordinatesにする
        let text = texts.joined(separator: " ")
        return Coordinates(text)
    }
}
