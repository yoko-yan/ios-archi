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
    init(recognizedTextsRepository: RecognizedTextsRepository = RecognizedTextsRepositoryImpl()) {
        self.recognizedTextsRepository = recognizedTextsRepository
    }

    func execute(image: UIImage) async throws -> Seed? {
        let texts = try await recognizedTextsRepository.get(image: image)
        // シード値に余計な文字がついてしまったケースを考慮し、読み取れた文字を１つの文字列にして、シード値の形式にマッチするものをSeedにする
        let text = texts.joined(separator: " ")

        let regex = Regex {
            Capture {
                Optionally("-")
                OneOrMore(.digit)
            }
        }
        // 読み取れた数字が複数ある場合は、より桁数が大きい数字をSeedにする
        let filterdTexs = text.matches(of: regex).map(\.output.1)
        guard let max = filterdTexs.max(by: { a, b -> Bool in
            a.count < b.count
        }) else { return nil }
        return Seed(String(max))
    }

//    func execute(image: UIImage) -> AnyPublisher<Seed?, RecognizeTextLocalRequestError> {
//        recognizedTextsRepository.get(image: image)
//            .map { (texts: [String]) -> Seed? in
//                // 読み取れた数字が複数ある場合は、より大きい数字をSeedにする
//                let filterdTexs = texts.compactMap { Seed($0) }
//                guard let max = filterdTexs.max(by: { a, b -> Bool in
//                    a.rawValue < b.rawValue
//                }) else { return nil }
//                return max
//            }
//            .eraseToAnyPublisher()
//    }
}
