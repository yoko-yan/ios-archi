//
//  Created by apla on 2023/10/08
//

import Foundation
import UIKit

// MARK: - Action

enum SpotViewAction {
    case load
    case reload
}

// MARK: - View model

@MainActor
final class SpotListViewModel: ObservableObject {
    @Published private(set) var uiState = SpotListUiState()

    init(uiState: SpotListUiState = SpotListUiState()) {
        self.uiState = uiState
    }

    func send(_ action: SpotViewAction) {
        switch action {
        case .load:
            Task {
                uiState.items = try await ItemsRepository().load()
            }

        case .reload:
            send(.load)
        }
    }

    func loadImage(fileName: String?) -> UIImage? {
        ImageRepository().load(fileName: fileName)
    }
}
