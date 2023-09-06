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

        let regex = Regex {
            TryCapture {
                Optionally("-")
                Repeat(.digit, 1...4)
            } transform: {
                Int($0)
            }
            Optionally(.whitespace)
            ChoiceOf {
                ","
                "."
            }
            Optionally(.whitespace)
            TryCapture {
                Optionally("-")
                Repeat(.digit, 1...4)
            } transform: {
                Int($0)
            }
            Optionally(.whitespace)
            ChoiceOf {
                ","
                "."
            }
            Optionally(.whitespace)
            TryCapture {
                Optionally("-")
                Repeat(.digit, 1...4)
            } transform: {
                Int($0)
            }
        }

        if let match = text.firstMatch(of: regex) {
            let (_, x, y, z) = match.output
            return Coordinates(x: x, y: y, z: z)
        }
        return nil
    }
}
