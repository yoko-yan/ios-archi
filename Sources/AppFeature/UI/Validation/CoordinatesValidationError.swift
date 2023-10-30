//
//  Created by apla on 2023/10/29
//

import Foundation

enum CoordinatesValidationError {
    case x
    case y
    case z
}

extension CoordinatesValidationError: ValidationError {
    var errorDescription: String? {
        switch self {
        case .x: return "Xに数字を入力してください"
        case .y: return "Yに数字を入力してください"
        case .z: return "Zに数字を入力してください"
        }
    }
}

enum CoordinatesValidator {
    static func validate(x text: String) -> ValidationResult<CoordinatesValidationError> {
        guard Int(text) != nil else { return .invalid(.x) }
        return .valid
    }

    static func validate(y text: String) -> ValidationResult<CoordinatesValidationError> {
        guard Int(text) != nil else { return .invalid(.y) }
        return .valid
    }

    static func validate(z text: String) -> ValidationResult<CoordinatesValidationError> {
        guard Int(text) != nil else { return .invalid(.z) }
        return .valid
    }
}
