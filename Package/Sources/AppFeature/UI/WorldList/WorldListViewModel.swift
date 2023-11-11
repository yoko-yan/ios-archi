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

    func send(action: WorldListViewAction) async {
        switch action {
        case .load:
            do {
                uiState.worlds = try await WorldsRepository().fetchAll()
            } catch {
                print(error)
            }
        case .reload:
            await send(action: .load)
        case let .onDeleteButtonClick(offsets: offsets):
            print(offsets.map { uiState.worlds[$0] })
            uiState.deleteWorlds = offsets.map { uiState.worlds[$0] }
            uiState.deleteAlertMessage = "削除しますか？"
        case .onDelete:
            if let deleteWorlds = uiState.deleteWorlds {
//                for await world in deleteWorlds {
//                    do {
//                        try await WorldsRepository().delete(world: world)
//                        await send(action: .reload)
//                    } catch {
//                        print(error)
//                    }
//                }
            } else {
                fatalError("no deleteItems")
            }
        case .onDeleteAlertDismiss:
            uiState.deleteAlertMessage = nil
        }
    }
}
