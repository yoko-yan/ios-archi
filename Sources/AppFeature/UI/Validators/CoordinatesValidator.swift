//
//  Created by apla on 2023/10/29
//

import Foundation

enum CoordinatesValidator: Error {
    case invalid
    case invalidX
    case invalidY
    case invalidZ
}

extension CoordinatesValidator {
    static func validate(_ text: String) -> CoordinatesValidator {
        if Coordinates(text) == nil { return .invalid }
        return .invalid
    }

    static func validateX(_ text: String) throws -> Bool {
        guard let value = Int(text) else { return false }
        return Coordinates.validateX(value)
    }

    static func validateY(_ text: String) throws -> Bool {
        guard let value = Int(text) else { return false }
        return Coordinates.validateX(value)
    }

    static func validateZ(_ text: String) throws -> Bool {
        guard let value = Int(text) else { return false }
        return Coordinates.validateX(value)
    }
}
