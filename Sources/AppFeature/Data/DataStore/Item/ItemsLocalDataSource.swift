//
//  Created by takayuki.yokoda on 2023/07/01.
//

import Foundation

struct ItemsLocalDataSource: ItemsDataSource {
    private static let key = "ItemsDataStoreInStorage"

    func save(items: [Item]) {
        guard let data = try? JSONEncoder().encode(items) else { fatalError() }
        UserDefaults.standard.set(data, forKey: Self.key)
    }

    func load() -> [Item] {
        guard let data = UserDefaults.standard.object(forKey: Self.key) as? Data,
              let items = try? JSONDecoder().decode([Item].self, from: data)
        else { return [] }
        return items.sorted(by: { $0.createdAt < $1.createdAt })
    }

    func insert(item: Item) {
        // TODO:
        fatalError()
    }

    func update(item: Item) {
        do {
            var items = try load()
            if let index = items.firstIndex(where: { $0.id == item.id }) {
                items[index] = item
            } else {
                items.append(item)
            }
            try save(items: items)
        } catch {
            print(error)
        }
    }
}
