//
//  Created by yoko-yan on 2023/10/08
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

    init() {
        uiState = SpotListUiState()
    }

    func send(action: SpotViewAction) async {
        switch action {
        case .load:
            do {
                uiState.items = try await ItemsRepositoryImpl().fetchAll()
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
            uiState.spotImages[item.id] = try await LoadSpotImageUseCaseImpl().execute(fileName: imageName).map { SpotImage(imageName: nil, image: $0) }
        }
    }
}
