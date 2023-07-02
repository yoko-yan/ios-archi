//
//  ListViewModel.swift
//
//
//  Created by takayuki.yokoda on 2023/07/01.
//

import Foundation
import UIKit

@MainActor
final class ListViewModel: ObservableObject {
    @Published private(set) var uiState = ListUiState()

    func loadItems() {
        uiState.items = ItemsRepository().load()
    }

    func loadImage(itemsId: String) -> UIImage? {
        ImageRepository().load(fileName: "\(itemsId)_coordinates")
    }

    init(uiState: ListUiState = ListUiState()) {
        self.uiState = uiState
    }
}
