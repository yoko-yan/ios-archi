//
//  Created by yoko-yan on 2023/10/15
//

import Foundation
import SwiftUI
import UIKit

struct CoordinatesEditUiState {
    enum Event: Equatable {
        case onChanged
    }

    var coordinatesXText: String
    var coordinatesYText: String
    var coordinatesZText: String
    var coordinates: Coordinates? {
        if coordinatesXText == "", // swiftlint:disable:this empty_string
           coordinatesYText == "", // swiftlint:disable:this empty_string
           coordinatesZText == "" // swiftlint:disable:this empty_string
        {
            return nil
        }
        return Coordinates(
            x: Int(coordinatesXText) ?? 0,
            y: Int(coordinatesYText) ?? 0,
            z: Int(coordinatesZText) ?? 0
        )
    }

    var coordinatesImage: UIImage?
    var validationErrors: [CoordinatesValidationError] = []
    var events: [Event] = []

    var valid: Bool {
        validationErrors.isEmpty
    }
}
