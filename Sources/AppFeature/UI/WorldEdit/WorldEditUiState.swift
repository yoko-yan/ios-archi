//
//  Created by yoko-yan on 2023/10/08
//

import Foundation
import SwiftUI
import UIKit

struct WorldEditUiState {
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
        case onChanged
        case onDeleted
        case onDismiss
    }

    enum EditMode: Equatable {
        case new
        case edit(World)

        var title: String {
            switch self {
            case .new: return "ワールドを新規に登録する"
            case .edit: return "ワールド情報を変更する"
            }
        }

        var button: String {
            switch self {
            case .new: return "登録する"
            case .edit: return "変更する"
            }
        }

        init(world: World?) {
            if let world {
                self = .edit(world)
            } else {
                self = .new
            }
        }

        var world: World? {
            switch self {
            case .new: return nil
            case let .edit(world): return world
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
    var error: WorldEditError?
    var validationErrors: [SeedValidationError] = []
    var events: [Event] = []
    var input: Input
    var seedImage: UIImage?

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

    var valid: Bool {
        validationErrors.isEmpty
    }
}
