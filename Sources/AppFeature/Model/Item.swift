//
//  Created by yoko-yan on 2023/07/01.
//

import Foundation

struct Item: Identifiable, Hashable {
    var id: String
    private(set) var coordinates: Coordinates?
    var world: World?
    var spotImageName: String?
    var createdAt: Date
    var updatedAt: Date
}
