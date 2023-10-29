//
//  Created by yoko-yan on 2023/07/01.
//

import Foundation

struct Item: Identifiable, Hashable {
    let id: String
    let coordinates: Coordinates?
    let world: World?
    let spotImageName: String?
    let createdAt: Date
    let updatedAt: Date
}
