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

    var coordinatesX: String
    var coordinatesY: String
    var coordinatesZ: String
    var coordinates: Coordinates? {
        if coordinatesX == "", // swiftlint:disable:this empty_string
           coordinatesY == "", // swiftlint:disable:this empty_string
           coordinatesZ == "" // swiftlint:disable:this empty_string
        {
            return nil
        }
        return Coordinates(
            x: Int(coordinatesX) ?? 0,
            y: Int(coordinatesY) ?? 0,
            z: Int(coordinatesZ) ?? 0
        )
    }

    var coordinatesImage: UIImage?
    var validationErrors: [CoordinatesValidationError] = []
    var events: [Event] = []

    var valid: Bool {
        validationErrors.isEmpty
    }
}
