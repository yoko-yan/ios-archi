//
//  EditItemUiState.swift
//
//
//  Created by takayuki.yokoda on 2023/07/03.
//

import Foundation
import UIKit

struct EditItemUiState: Equatable {
    enum EditMode: Equatable {
        case add
        case update

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
    }

    let editMode: EditMode

    var editItem: Item
    var seedImage: UIImage?
    var coordinatesImage: UIImage?
}
