//
//  Created by takayuki.yokoda on 2023/07/03.
//

import Foundation
import UIKit

struct EditItemUiState: Equatable {
    enum AlertType {
        case none
        case confirmUpdate
        case confirmDeletion

        enum ButtonType {
            case none
            case destructive
        }

        var message: String {
            switch self {
            case .none:
                return ""

            case .confirmUpdate:
                return "更新してもいいですか？"

            case .confirmDeletion:
                return "削除してもいいですか？"
            }
        }

        var buttonType: ButtonType {
            switch self {
            case .none:
                return .none

            case .confirmUpdate:
                return .none

            case .confirmDeletion:
                return .destructive
            }
        }
    }

    enum Event: Equatable {
        case updated
        case deleted
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
            case .add: return "登録する"
            case .update: return "更新する"
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

    let editMode: EditMode

    var alertType: AlertType = .none
    var event: Event?
    var input: Input
    var seedImage: UIImage?
    var coordinatesImage: UIImage?

    var editItem: Item {
        Item(
            id: input.id ?? UUID().uuidString,
            coordinates: input.coordinates,
            seed: input.seed,
            coordinatesImageName: input.coordinatesImageName,
            seedImageName: input.seedImageName,
            createdAt: editMode.item?.createdAt ?? Date(),
            updatedAt: editMode.item?.updatedAt ?? Date()
        )
    }
}
