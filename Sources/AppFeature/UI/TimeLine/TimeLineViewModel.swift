//
//  Created by yoko-yan on 2023/10/07
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

    func send(action: TimeLineViewAction) {
        switch action {
        case .load:
            Task {
                uiState.items = try await ItemsRepository().load()
            }

        case .reload:
            send(action: .load)
        }
    }

    func loadImage(item: Item) {
        guard let imageName = item.spotImageName else { return }
        Task {
            uiState.spotImages[item.id] = try await RemoteImageRepository().load(fileName: imageName).map { SpotImage(imageName: nil, image: $0) }
        }
    }
}
