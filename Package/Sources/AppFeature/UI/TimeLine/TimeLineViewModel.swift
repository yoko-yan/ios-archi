//
//  Created by yoko-yan on 2023/10/07
//

import Core
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
    @Injected(\.itemsRepository) var itemsRepository

    @Published private(set) var uiState = TimeLineUiState()

    init(uiState: TimeLineUiState = TimeLineUiState()) {
        self.uiState = uiState
    }

    func send(action: TimeLineViewAction) async {
        switch action {
        case .load:
            do {
                uiState.items = try await itemsRepository.fetchWithoutNoPhoto()
            } catch {
                print(error)
            }
        case .reload:
            await send(action: .load)
        }
    }

    func loadImage(item: Item) {
        guard let imageName = item.spotImageName else { return }
        Task {
            uiState.spotImages[item.id] = try await LoadSpotImageUseCaseImpl().execute(fileName: imageName)
                .map { SpotImage(imageName: nil, image: $0) }
        }
    }
}
