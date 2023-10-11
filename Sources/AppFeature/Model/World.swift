////
////  Created by takayuki.yokoda on 2023/10/11
////
//
import Foundation

struct World: Identifiable, Hashable, Codable {
    var id: String
    let name: String?
    let seed: Seed?
    var createdAt: Date
    var updatedAt: Date
}
