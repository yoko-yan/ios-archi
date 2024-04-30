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
                return "May I make changes?"
            case .confirmDeletion:
                return "May I delete it?"
            case .confirmDismiss:
                return "There is data being edited.\nIs it okay to close without making any changes?"
            }
        }

        var buttonLabel: String {
            switch self {
            case .confirmUpdate:
                return "Change"
            case .confirmDeletion:
                return "Delete"
            case .confirmDismiss:
                return "Cancel changes"
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
            case .new: return String(localized: "Register a world", bundle: .module)
            case .edit: return String(localized: "Modify the world", bundle: .module)
            }
        }

        var button: String {
            switch self {
            case .new: return String(localized: "Register", bundle: .module)
            case .edit: return String(localized: "Modify", bundle: .module)
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
        var name: String?
        var seed: Seed?

        init(world: World?) {
            id = world?.id
            name = world?.name
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
            name: input.name,
            seed: input.seed,
            createdAt: editMode.world?.createdAt ?? Date(),
            updatedAt: editMode.world?.updatedAt ?? Date()
        )
    }

    var isChanged: Bool {
        if editItem.name == editMode.world?.name,
           editItem.seed == editMode.world?.seed
        {
            false
        } else {
            true
        }
    }

    var valid: Bool {
        validationErrors.isEmpty
    }
}
