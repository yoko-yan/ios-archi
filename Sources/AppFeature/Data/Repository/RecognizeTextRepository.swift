//
//  Created by yokoda.takayuki on 2023/07/27
//

import Combine
import Foundation
import UIKit

protocol RecognizeTextRepository {
    func get(image: UIImage) -> AnyPublisher<[String], RecognizeTextError>
}

struct RecognizeTextRepositoryImpl: RecognizeTextRepository {
    func get(image: UIImage) -> AnyPublisher<[String], RecognizeTextError> {
        RecognizeTextRequest().perform(image: image)
            .filter { !$0.isEmpty }
            .eraseToAnyPublisher()
    }
}
