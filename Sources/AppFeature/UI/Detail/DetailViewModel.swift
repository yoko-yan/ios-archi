//
//  DetailViewModel.swift
//  ios-archi
//
//  Created by yokoda.takayuki on 2023/01/28.
//

import Combine
import SwiftUI
import UIKit

@MainActor
final class DetailViewModel: ObservableObject {
    @Published private(set) var uiState: DetailUiState

    private var cancellables: Set<AnyCancellable> = []

    var item: Binding<Item> {
        Binding(
            get: { self.uiState.item },
            set: { newValue in
                self.uiState.item = newValue
            }
        )
    }

    var seedImage: Binding<UIImage?> {
        Binding(
            get: { self.uiState.seedImage },
            set: { newValue in
                self.uiState.seedImage = newValue
            }
        )
    }

    var coordinatesImage: Binding<UIImage?> {
        Binding(
            get: { self.uiState.coordinatesImage },
            set: { newValue in
                self.uiState.coordinatesImage = newValue
            }
        )
    }

    init(item: Item) {
        uiState = DetailUiState(item: item)
    }

    func loadImage() {
        uiState.seedImage = ImageRepository().load(fileName: "\(uiState.item.id)_seed")
        uiState.coordinatesImage = ImageRepository().load(fileName: "\(uiState.item.id)_coordinates")
    }
}
