//
//  Created by takayuki.yokoda on 2023/07/01.
//

import Foundation
import UIKit

// MARK: - Action

enum ListViewAction {
    case load
    case reload
    case onDeleteButtonClick(offsets: IndexSet)
    case onDelete
    case onDeleteAlertDismiss
}

// MARK: - View model

@MainActor
final class ListViewModel: ObservableObject {
    @Published private(set) var uiState = ListUiState()

    init(uiState: ListUiState = ListUiState()) {
        self.uiState = uiState
    }

    func send(_ action: ListViewAction) {
        switch action {
        case .load:
            Task {
                uiState.items = try await ItemRepository().load()
            }
        case .reload:
            send(.load)
        case let .onDeleteButtonClick(offsets: offsets):
            print(offsets.map { uiState.items[$0] })
            uiState.deleteItems = offsets.map { uiState.items[$0] }
            uiState.deleteAlertMessage = "削除しますか？"
        case .onDelete:
            if let deleteItems = uiState.deleteItems {
                deleteItems.forEach { item in
                    Task {
                        try await ItemRepository().delete(item: item)
                        send(.reload)
                    }
                }
            } else {
                fatalError("no deleteItems")
            }
        case .onDeleteAlertDismiss:
            uiState.deleteAlertMessage = nil
        }
    }

    func loadImage(fileName: String?) -> UIImage? {
        ImageRepository().load(fileName: fileName)
    }
}
