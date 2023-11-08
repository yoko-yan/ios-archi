//
//  Created by yoko-yan on 2023/10/08
//

import Core
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
    @Injected(\.itemsRepository) var itemsRepository
    @Injected(\.loadSpotImageUseCase) var loadSpotImageUseCase

    @Published private(set) var uiState = SpotListUiState()

    init(uiState: SpotListUiState = .init()) {
        self.uiState = uiState
    }

    func send(action: SpotViewAction) async {
        switch action {
        case .load:
            do {
                uiState.items = try await itemsRepository.fetchAll()
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
            uiState.spotImages[item.id] = try await loadSpotImageUseCase.execute(fileName: imageName).map { SpotImage(imageName: nil, image: $0) }
        }
    }
}
