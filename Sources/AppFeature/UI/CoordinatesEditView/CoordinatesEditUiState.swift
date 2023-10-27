//
//  Created by yoko-yan on 2023/10/15
//

import Foundation
import SwiftUI
import UIKit

struct CoordinatesEditUiState: Equatable {
    var coordinates: String?
    var coordinatesX: String? {
        if let coordinates,
           coordinates.components(separatedBy: ",").count > 0 // swiftlint:disable:this empty_count
        {
            return coordinates.components(separatedBy: ",")[0]
        }
        return nil
    }

    var coordinatesY: String? {
        if let coordinates,
           coordinates.components(separatedBy: ",").count > 1
        {
            return coordinates.components(separatedBy: ",")[1]
        }
        return nil
    }

    var coordinatesZ: String? {
        if let coordinates,
           coordinates.components(separatedBy: ",").count > 2
        {
            return coordinates.components(separatedBy: ",")[2]
        }
        return nil
    }

    var coordinatesImage: UIImage?
}
