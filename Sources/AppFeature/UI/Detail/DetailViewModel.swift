//
//  Created by yokoda.takayuki on 2023/01/28.
//

import Combine
import SwiftUI
import UIKit

@MainActor
final class DetailViewModel: ObservableObject {
    @Published private(set) var uiState: DetailUiState

    init(item: Item) {
        uiState = DetailUiState(item: item)
    }

    func loadImage() {
        uiState.coordinatesImage = ImageRepository().load(fileName: uiState.item.coordinatesImageName)
        uiState.seedImage = ImageRepository().load(fileName: uiState.item.seedImageName)
    }

    func reload(item: Item) {
        uiState.item = item
        loadImage()
    }
}
