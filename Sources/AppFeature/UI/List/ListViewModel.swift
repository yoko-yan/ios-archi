//
//  Created by takayuki.yokoda on 2023/07/01.
//

import Foundation
import UIKit

// MARK: - Action

enum ListViewAction {
    case load
    case reload
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
                uiState.seeds = try await ItemRepository().allSeeds()
            }
        case .reload:
            send(.load)
        }
    }

    func loadImage(fileName: String?) -> UIImage? {
        ImageRepository().load(fileName: fileName)
    }
}
