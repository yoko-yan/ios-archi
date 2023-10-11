//
//  Created by yokoda.takayuki on 2023/01/28.
//

import Combine
import SwiftUI
import UIKit

// MARK: - View model

@MainActor
final class DetailViewModel: ObservableObject {
    @Published private(set) var uiState: DetailUiState

    init(item: Item) {
        uiState = DetailUiState(item: item)
    }

    func loadImage() {
        uiState.spotImageName = ImageRepository().load(fileName: uiState.item.spotImageName)
    }

    func reload(item: Item) {
        uiState.item = item
        loadImage()
    }
}
