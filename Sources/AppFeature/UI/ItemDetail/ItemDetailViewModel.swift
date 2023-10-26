//
//  Created by yokoda.takayuki on 2023/01/28.
//

import Combine
import SwiftUI
import UIKit

// MARK: - View model

@MainActor
final class ItemDetailViewModel: ObservableObject {
    @Published private(set) var uiState: ItemDetailUiState

    init(item: Item) {
        uiState = ItemDetailUiState(item: item)
    }

    func loadImage() {
        Task {
            uiState.spotImage = try await LoadSpotImageUseCaseImpl().execute(fileName: uiState.item.spotImageName ?? "")
        }
    }

    func reload(item: Item) {
        uiState.item = item
        loadImage()
    }
}
