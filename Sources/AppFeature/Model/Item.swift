//
//  Created by yoko-yan on 2023/07/01.
//

import Foundation

struct Item: Identifiable, Hashable, Codable {
    var id: String
    var coordinates: Coordinates?
    var world: World?
    var spotImageName: String?
    var createdAt: Date
    var updatedAt: Date
}
