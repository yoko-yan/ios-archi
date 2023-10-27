//
//  Created by yoko-yan on 2023/07/03.
//

import Foundation
import SwiftUI
import UIKit

struct ItemEditUiState: Equatable {
    enum AlertType: Equatable {
        case confirmUpdate(ItemEditViewAction)
        case confirmDeletion(ItemEditViewAction)
        case confirmDismiss(ItemEditViewAction)

        var message: String {
            switch self {
            case .confirmUpdate:
                return "変更してもいいですか？"

            case .confirmDeletion:
                return "変更してもいいですか？"

            case .confirmDismiss:
                return "編集中のデータがあります。\nデータを変更せずに閉じてもいいですか？"
            }
        }

        var buttonLabel: String {
            switch self {
            case .confirmUpdate:
                return "変更する"

            case .confirmDeletion:
                return "削除する"

            case .confirmDismiss:
                return "変更せずに戻る"
            }
        }

        var buttonRole: ButtonRole? {
            switch self {
            case .confirmUpdate, .confirmDismiss:
                return nil

            case .confirmDeletion:
                return .destructive
            }
        }

        var action: ItemEditViewAction {
            switch self {
            case let .confirmUpdate(action), let .confirmDismiss(action), let .confirmDeletion(action):
                return action
            }
        }
    }

    enum Event: Equatable {
        case onChanged
        case onDeleted
        case onDismiss
    }

    enum EditMode: Equatable {
        case add
        case update(Item)

        var title: String {
            switch self {
            case .add: return "スポットを新規に登録する"
            case .update: return "スポット情報を変更する"
            }
        }

        var button: String {
            switch self {
            case .add: return "登録する"
            case .update: return "変更する"
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
        var spotImageName: String?
        var coordinates: Coordinates?
        var world: World?

        init(item: Item?) {
            id = item?.id
            coordinates = item?.coordinates
            if let world = item?.world {
                self.world = world
            }
            spotImageName = item?.spotImageName
        }
    }

    let editMode: EditMode

    var confirmationAlert: AlertType?
    var event: [Event] = []
    var input: Input
    var spotImage: UIImage?
    var worlds: [World] = []

    var editItem: Item {
        Item(
            id: input.id ?? UUID().uuidString,
            coordinates: input.coordinates,
            world: input.world,
            spotImageName: input.spotImageName,
            createdAt: editMode.item?.createdAt ?? Date(),
            updatedAt: editMode.item?.updatedAt ?? Date()
        )
    }

    var isChanged: Bool {
        if editItem.world == editMode.item?.world,
           editItem.coordinates == editMode.item?.coordinates,
           editItem.spotImageName == editMode.item?.spotImageName
        {
            false
        } else {
            true
        }
    }
}
