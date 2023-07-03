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

    var input: Binding<EditItemUiState.Input> {
        Binding(
            get: { self.uiState.input },
            set: { newValue in
                self.uiState.input = newValue
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
        uiState = EditItemUiState(
            editMode: EditItemUiState.EditMode(item: item),
            input: EditItemUiState.Input(item: item)
        )
    }

    func clearSeed() {
        uiState.input.seed = nil
    }

    func clearCoordinates() {
        uiState.input.coordinates = nil
    }

    func getSeed(image: UIImage) {
        let repository = SeedRepository()
        repository.get(image: image)
            .sink { [weak self] seed in
                guard let self else { return }
                if !seed.isEmpty, let seedValue = Int(seed) {
                    uiState.input.seed = Seed(rawValue: seedValue)
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
                    uiState.input.coordinates = Coordinates(x: x, y: y, z: z)
                    return
                }
                uiState.input.coordinates = nil
            }
            .store(in: &cancellables)
    }

    func createItem() -> Item {
        Item(
            id: uiState.input.id ?? UUID().uuidString,
            coordinates: uiState.input.coordinates,
            seed: uiState.input.seed,
            coordinatesImageName: uiState.input.coordinatesImageName,
            seedImageName: uiState.input.seedImageName,
            createdAt: uiState.editMode.item?.createdAt ?? Date(),
            updatedAt: uiState.editMode.item?.updatedAt ?? Date()
        )
    }

    func insertItem() {
        ItemRepository().insert(item: createItem())
    }

    func updateItem() {
        ItemRepository().update(item: createItem())
    }

    func saveImage() {
        if let coordinatesImage = uiState.coordinatesImage {
            let coordinatesImageName = uiState.input.coordinatesImageName ?? UUID().uuidString
            uiState.input.coordinatesImageName = coordinatesImageName
            do {
                try ImageRepository().save(coordinatesImage, fileName: coordinatesImageName)
            } catch {
                print(error)
            }
        }

        if let seedImage = uiState.seedImage {
            let seedImageName = uiState.input.seedImageName ?? UUID().uuidString
            uiState.input.seedImageName = seedImageName
            do {
                try ImageRepository().save(seedImage, fileName: seedImageName)
            } catch {
                print(error)
            }
        }
    }

    func loadImage() {
        uiState.coordinatesImage = ImageRepository().load(fileName: uiState.input.coordinatesImageName)
        uiState.seedImage = ImageRepository().load(fileName: uiState.input.seedImageName)
    }
}
