//
//  Created by yokoda.takayuki on 2023/07/27
//

import Combine
import Dependencies
import Foundation
import UIKit

protocol GetSeed2UseCase {
    func execute(image: UIImage) -> AnyPublisher<Seed?, RecognizeTextError>
}

struct GetSeed2UseCaseImpl: GetSeed2UseCase {
    @Dependency(\.recognizeText2Repository) var recognizeText2Repository

    func execute(image: UIImage) -> AnyPublisher<Seed?, RecognizeTextError> {
        recognizeText2Repository.get(image: image)
            .map { (texts: [String]) -> Seed? in
                // 読み取れた数字が複数ある場合は、より大きい数字をSeedにする
                let filterdTexs = texts.compactMap { Seed($0) }
                guard let max = filterdTexs.max(by: { a, b -> Bool in
                    a.rawValue < b.rawValue
                }) else { return nil }
                return max
            }
            .eraseToAnyPublisher()
    }
}