//
//  Created by yokoda.takayuki on 2023/07/27
//

import Combine
import Foundation
import UIKit

protocol RecognizeTextRepository {
    func get(image: UIImage) async throws -> [String]
//    func get(image: UIImage, completionHandler: @escaping @Sendable (Result<[String], RecognizeTextError>) -> Void)
//    func get(image: UIImage) -> AnyPublisher<[String], RecognizeTextError>
}

struct RecognizeTextRepositoryImpl: RecognizeTextRepository {
    func get(image: UIImage) async throws -> [String] {
        try await RecognizeTextRequest().perform(image: image)
    }

//    func get(image: UIImage, completionHandler: @escaping @Sendable (Result<[String], RecognizeTextError>) -> Void) {
//        RecognizeTextRequest().perform(image: image) { result in
//            switch result {
//            case let .success(texts):
//                completionHandler(.success(texts))
//            case let .failure(error):
//                completionHandler(.failure(error))
//            }
//        }
//    }

//    func get(image: UIImage) -> AnyPublisher<[String], RecognizeTextError> {
//        RecognizeTextRequest().perform(image: image)
//            .filter { !$0.isEmpty }
//            .eraseToAnyPublisher()
//    }
}
