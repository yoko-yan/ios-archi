//
//  Created by yokoda.takayuki on 2023/07/27
//

import Combine
import Dependencies
import Foundation
import UIKit

protocol NewRecognizedTextsRepository: Sendable {
    func get(image: UIImage) async throws -> [String]
}

struct NewRecognizedTextsRepositoryImpl: NewRecognizedTextsRepository {
    func get(image: UIImage) async throws -> [String] {
        try await RecognizeTextLocalRequest().perform(image: image)
    }
}

struct NewRecognizedTextsRepositoryKey: DependencyKey {
    static let liveValue: any NewRecognizedTextsRepository = NewRecognizedTextsRepositoryImpl()
}

extension DependencyValues {
    var newRecognizedTextsRepository: any NewRecognizedTextsRepository {
        get { self[NewRecognizedTextsRepositoryKey.self] }
        set { self[NewRecognizedTextsRepositoryKey.self] = newValue }
    }
}
