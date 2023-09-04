//
//  Created by yokoda.takayuki on 2023/07/27
//

import Combine
import Foundation
import UIKit

protocol GetSeedUseCase {
    func execute(image: UIImage) async throws -> Seed?
//    func execute(image: UIImage) -> AnyPublisher<Seed?, RecognizeTextError>
}

struct GetSeedUseCaseImpl: GetSeedUseCase {
    private let recognizeTextRepository: RecognizeTextRepository
    init(recognizeTextRepository: RecognizeTextRepository = RecognizeTextRepositoryImpl()) {
        self.recognizeTextRepository = recognizeTextRepository
    }

    func execute(image: UIImage) async throws -> Seed? {
        let texts = try await recognizeTextRepository.get(image: image)
        // 読み取れた数字が複数ある場合は、より大きい数字をSeedにする
        let filterdTexs = texts.compactMap { Seed($0) }
        guard let max = filterdTexs.max(by: { a, b -> Bool in
            a.rawValue < b.rawValue
        }) else { return nil }
        return max
    }

//    func execute(image: UIImage) -> AnyPublisher<Seed?, RecognizeTextError> {
//        recognizeTextRepository.get(image: image)
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
