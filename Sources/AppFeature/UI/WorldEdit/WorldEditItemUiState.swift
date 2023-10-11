//
//  Created by apla on 2023/10/08
//

import Foundation
import SwiftUI
import UIKit

struct WorldEditItemUiState: Equatable {
    enum AlertType: Equatable {
        case confirmUpdate(WorldEditViewAction)
        case confirmDeletion(WorldEditViewAction)
        case confirmDismiss(WorldEditViewAction)

        var message: String {
            switch self {
            case .confirmUpdate:
                return "変更してもいいですか？"

            case .confirmDeletion:
                return "削除してもいいですか？"

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

        var action: WorldEditViewAction {
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
        case update(World)

        var title: String {
            switch self {
            case .add: return "ワールドを新規に登録する"
            case .update: return "ワールド情報を変更する"
            }
        }

        var button: String {
            switch self {
            case .add: return "登録する"
            case .update: return "変更する"
            }
        }

        init(world: World?) {
            if let world {
                self = .update(world)
            } else {
                self = .add
            }
        }

        var world: World? {
            switch self {
            case .add: return nil
            case let .update(world): return world
            }
        }
    }

    struct Input: Equatable {
        var id: String?
        var seed: Seed?
        var seedImageName: String?

        init(world: World?) {
            id = world?.id
            seed = world?.seed
        }
    }

    let editMode: EditMode

    var confirmationAlert: AlertType?
    var event: Event?
    var input: Input
    var seedImage: UIImage?
    var seed: [World] = []

    var editItem: World {
        World(
            id: input.id ?? UUID().uuidString,
            name: "",
            seed: input.seed,
            createdAt: editMode.world?.createdAt ?? Date(),
            updatedAt: editMode.world?.updatedAt ?? Date()
        )
    }

    var isChanged: Bool {
        if editItem.seed == editMode.world?.seed {
            false
        } else {
            true
        }
    }
}
