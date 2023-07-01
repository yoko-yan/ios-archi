//
//  ListViewModel.swift
//
//
//  Created by takayuki.yokoda on 2023/07/01.
//

import Foundation

@MainActor
final class ListViewModel: ObservableObject {
    @Published private(set) var uiState = ListUiState()

    func loadItems() {
        uiState.items = ItemsRepository().load()
    }

    init(uiState: ListUiState = ListUiState()) {
        self.uiState = uiState
    }
}
