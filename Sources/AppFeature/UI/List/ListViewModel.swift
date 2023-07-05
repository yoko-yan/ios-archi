//
//  Created by takayuki.yokoda on 2023/07/01.
//

import Foundation
import UIKit

@MainActor
final class ListViewModel: ObservableObject {
    @Published private(set) var uiState = ListUiState()

    init(uiState: ListUiState = ListUiState()) {
        self.uiState = uiState
    }

    func loadItems() {
        uiState.items = ItemRepository().load()
    }

    func loadImage(fileName: String?) -> UIImage? {
        ImageRepository().load(fileName: fileName)
    }

    func reload() {
        loadItems()
    }
}
