//
//  Created by apla on 2023/10/29
//

import Foundation

enum ValidationResult<T> {
    case valid
    case invalid(T)

    var validationError: T? {
        if case let .invalid(validationError) = self {
            return validationError
        }
        return nil
    }
}
