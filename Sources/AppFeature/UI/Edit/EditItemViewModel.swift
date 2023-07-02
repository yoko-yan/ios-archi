//
//  EditItemViewModel.swift
//
//
//  Created by takayuki.yokoda on 2023/07/03.
//

import Combine
import SwiftUI
import UIKit

@MainActor
final class EditItemViewModel: ObservableObject {
    @Published private(set) var uiState: EditItemUiState

    private var cancellables: Set<AnyCancellable> = []

    var editItem: Binding<Item> {
        Binding(
            get: { self.uiState.editItem },
            set: { newValue in
                self.uiState.editItem = newValue
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

    init(item: Item?) {
        let editItem: Item
        let editMode: EditItemUiState.EditMode
        if let item {
            editItem = item
            editMode = .update
        } else {
            editItem = Item()
            editMode = .add
        }
        uiState = EditItemUiState(editMode: editMode, editItem: editItem)
    }

    func clearSeed() {
        uiState.editItem.seed = nil
    }

    func clearCoordinates() {
        uiState.editItem.coordinates = nil
    }

    func getSeed(image: UIImage) {
        let repository = SeedRepository()
        repository.get(image: image)
            .sink { [weak self] seed in
                guard let self else { return }
                if !seed.isEmpty, let seedValue = Int(seed) {
                    uiState.editItem.seed = Seed(rawValue: seedValue)
                    return
                }
            }
            .store(in: &cancellables)
    }

    func getCoordinates(image: UIImage) {
        let repository = CoordinatesRepository()
        repository.get(image: image)
            .sink { [weak self] coordinates in
                guard let self else { return }
                let arr = coordinates.components(separatedBy: ",")
                if arr.count >= 3,
                   let x = Int(arr[0].trimmingCharacters(in: .whitespaces)),
                   let y = Int(arr[1].trimmingCharacters(in: .whitespaces)),
                   let z = Int(arr[2].trimmingCharacters(in: .whitespaces))
                {
                    uiState.editItem.coordinates = Coordinates(x: x, y: y, z: z)
                    return
                }
                uiState.editItem.coordinates = nil
            }
            .store(in: &cancellables)
    }

    func updateItem() {
        if let seedImage = uiState.seedImage {
            ImageRepository().save(seedImage, fileName: "\(uiState.editItem.id)_seed")
        }
        if let coordinatesImage = uiState.coordinatesImage {
            ImageRepository().save(coordinatesImage, fileName: "\(uiState.editItem.id)_coordinates")
        }
        ItemsRepository().update(item: uiState.editItem)
    }

    func loadImage() {
        uiState.seedImage = ImageRepository().load(fileName: "\(uiState.editItem.id)_seed")
        uiState.coordinatesImage = ImageRepository().load(fileName: "\(uiState.editItem.id)_coordinates")
    }
}
