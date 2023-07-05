//
//  Created by takayuki.yokoda on 2023/07/03.
//

import Foundation
import UIKit

struct EditItemUiState: Equatable {
    struct Input: Equatable {
        var id: String?
        var coordinates: Coordinates?
        var seed: Seed?
        var coordinatesImageName: String?
        var seedImageName: String?

        init(item: Item?) {
            id = item?.id
            if let coordinates = item?.coordinates {
                self.coordinates = Coordinates(
                    x: coordinates.x,
                    y: coordinates.y,
                    z: coordinates.z
                )
            }
            if let seed = item?.seed {
                self.seed = seed
            }
            coordinatesImageName = item?.coordinatesImageName
            seedImageName = item?.seedImageName
        }
    }

    enum EditMode: Equatable {
        case add
        case update(Item)

        var title: String {
            switch self {
            case .add: return "新規"
            case .update: return "編集"
            }
        }

        var button: String {
            switch self {
            case .add: return "追加"
            case .update: return "更新"
            }
        }

        init(item: Item?) {
            if let item {
                self = .update(item)
            } else {
                self = .add
            }
        }

        var item: Item? {
            switch self {
            case .add: return nil
            case let .update(item): return item
            }
        }
    }

    let editMode: EditMode

    var input: Input
    var seedImage: UIImage?
    var coordinatesImage: UIImage?
}
