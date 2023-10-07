//
//  Created by takayuki.yokoda on 2023/07/01.
//

import Foundation
import UIKit

// MARK: - Action

enum WorldListViewAction {
    case load
    case reload
}

// MARK: - View model

@MainActor
final class WorldListViewModel: ObservableObject {
    @Published private(set) var uiState = WorldListUiState()

    init(uiState: WorldListUiState = WorldListUiState()) {
        self.uiState = uiState
    }

    func send(_ action: WorldListViewAction) {
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
