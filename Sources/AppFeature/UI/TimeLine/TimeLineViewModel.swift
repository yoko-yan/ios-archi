//
//  Created by takayuki.yokoda on 2023/10/07
//

import Foundation
import UIKit

// MARK: - Action

enum TimeLineViewAction {
    case load
    case reload
}

// MARK: - View model

@MainActor
final class TimeLineViewModel: ObservableObject {
    @Published private(set) var uiState = TimeLineUiState()

    init(uiState: TimeLineUiState = TimeLineUiState()) {
        self.uiState = uiState
    }

    func send(_ action: TimeLineViewAction) {
        switch action {
        case .load:
            Task {
                uiState.items = try await ItemsRepository().load()
            }

        case .reload:
            send(.load)
        }
    }
}
