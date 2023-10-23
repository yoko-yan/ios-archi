//
//  Created by yoko-yan on 2023/07/01.
//

import Foundation
import UIKit

// MARK: - Action

enum WorldListViewAction {
    case load
    case reload
    case onDeleteButtonClick(offsets: IndexSet)
    case onDelete
    case onDeleteAlertDismiss
}

// MARK: - View model

@MainActor
final class WorldListViewModel: ObservableObject {
    @Published private(set) var uiState = WorldListUiState()

    init() {
        uiState = WorldListUiState()
    }

    func send(action: WorldListViewAction) {
        switch action {
        case .load:
            Task {
                uiState.worlds = try await WorldsRepository().load()
            }

        case .reload:
            send(action: .load)

        case let .onDeleteButtonClick(offsets: offsets):
            print(offsets.map { uiState.worlds[$0] })
            uiState.deleteWorlds = offsets.map { uiState.worlds[$0] }
            uiState.deleteAlertMessage = "削除しますか？"

        case .onDelete:
            if let deleteWorlds = uiState.deleteWorlds {
                deleteWorlds.forEach { world in
                    Task {
                        try await WorldsRepository().delete(world: world)
                        send(action: .reload)
                    }
                }
            } else {
                fatalError("no deleteItems")
            }

        case .onDeleteAlertDismiss:
            uiState.deleteAlertMessage = nil
        }
    }
}
