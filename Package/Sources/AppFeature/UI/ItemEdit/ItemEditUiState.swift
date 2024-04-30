//
//  Created by yoko-yan on 2023/07/03.
//

import Foundation
import SwiftUI
import UIKit

struct ItemEditUiState {
    enum AlertType: Equatable {
        case confirmUpdate(ItemEditViewAction)
        case confirmDeletion(ItemEditViewAction)
        case confirmDismiss(ItemEditViewAction)

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
                return "Modify"
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
        case new
        case edit(Item)

        var title: String {
            switch self {
            case .new: return String(localized: "Register a spot", bundle: .module)
            case .edit: return String(localized: "Modify the spot", bundle: .module)
            }
        }

        var button: String {
            switch self {
            case .new: return String(localized: "Register", bundle: .module)
            case .edit: return String(localized: "Modify", bundle: .module)
            }
        }

        init(item: Item?) {
            if let item {
                self = .edit(item)
            } else {
                self = .new
            }
        }

        var item: Item? {
            switch self {
            case .new: return nil
            case let .edit(item): return item
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
    var error: ItemEditError?
    var events: [Event] = []
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
        if editItem.spotImageName == editMode.item?.spotImageName,
           editItem.coordinates == editMode.item?.coordinates,
           editItem.world == editMode.item?.world
        {
            false
        } else {
            true
        }
    }
}
