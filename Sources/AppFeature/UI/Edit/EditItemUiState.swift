//
//  Created by takayuki.yokoda on 2023/07/03.
//

import Foundation
import SwiftUI
import UIKit

struct EditItemUiState: Equatable {
    enum AlertType: Equatable {
        case confirmUpdate(EditViewAction)
        case confirmDeletion(EditViewAction)
        case confirmDismiss(EditViewAction)

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

        var action: EditViewAction {
            switch self {
            case let .confirmUpdate(action), let .confirmDismiss(action), let .confirmDeletion(action):
                return action
            }
        }
    }

    enum Event: Equatable {
        case updated
        case deleted
        case dismiss
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
        var coordinates: String?
        var world: World?
        var spotImageName: String?

        init(item: Item?) {
            id = item?.id
            coordinates = item?.coordinates?.text
            if let world = item?.world {
                self.world = world
            }
            spotImageName = item?.spotImageName
        }
    }

    let editMode: EditMode

    var confirmationAlert: AlertType?
    var event: Event?
    var input: Input
    var spotImage: UIImage?
    var worlds: [World] = []

    var editItem: Item {
        Item(
            id: input.id ?? UUID().uuidString,
            coordinates: Coordinates(input.coordinates ?? ""),
            world: input.world,
            spotImageName: input.spotImageName,
            seedImageName: nil,
            createdAt: editMode.item?.createdAt ?? Date(),
            updatedAt: editMode.item?.updatedAt ?? Date()
        )
    }

    var isChanged: Bool {
        if editItem.world == editMode.item?.world,
           editItem.coordinates == editMode.item?.coordinates,
           editItem.spotImageName == editMode.item?.spotImageName,
           editItem.seedImageName == editMode.item?.seedImageName
        {
            false
        } else {
            true
        }
    }
}
