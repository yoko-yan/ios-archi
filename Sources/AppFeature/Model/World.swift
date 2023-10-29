////
////  Created by yoko-yan on 2023/10/11
////
//
import Foundation

struct World: Identifiable, Hashable {
    let id: String
    let name: String?
    let seed: Seed?
    let createdAt: Date
    let updatedAt: Date
}
