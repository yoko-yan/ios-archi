//
//  Created by takayuki.yokoda on 2023/07/02.
//

import Foundation

protocol ItemsDataSource {
    func save(items: [Item]) async throws
    func load() async throws -> [Item]
    func insert(item: Item) async throws
    func update(item: Item) async throws
    func delete(item: Item) async throws
}
