//
//  Created by yokoda.takayuki on 2023/07/27
//

import Combine
import Dependencies
import Foundation
import UIKit

protocol RecognizeText2Repository {
    func get(image: UIImage) -> AnyPublisher<[String], RecognizeTextError>
}

struct RecognizeText2RepositoryImpl: RecognizeText2Repository {
    func get(image: UIImage) -> AnyPublisher<[String], RecognizeTextError> {
        RecognizeTextRequest().perform(image: image)
            .filter { !$0.isEmpty }
            .eraseToAnyPublisher()
    }
}

struct RecognizeText2RepositoryKey: DependencyKey {
    static let liveValue: any RecognizeText2Repository = RecognizeText2RepositoryImpl()
}

extension DependencyValues {
    var recognizeText2Repository: any RecognizeText2Repository {
        get { self[RecognizeText2RepositoryKey.self] }
        set { self[RecognizeText2RepositoryKey.self] = newValue }
    }
}
