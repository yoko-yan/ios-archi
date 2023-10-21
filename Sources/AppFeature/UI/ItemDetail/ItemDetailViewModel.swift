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
//        uiState.spotImage = ImageRepository().load(fileName: uiState.item.spotImageName)
        let url = FileManager.default.url(forUbiquityContainerIdentifier: nil)!
            .appendingPathComponent("Documents")
            .appendingPathComponent(uiState.item.spotImageName ?? "")
        guard let data = try? Data(contentsOf: url) else { return }
        uiState.spotImage = UIImage(data: data)
    }

    func reload(item: Item) {
        uiState.item = item
        loadImage()
    }
}
