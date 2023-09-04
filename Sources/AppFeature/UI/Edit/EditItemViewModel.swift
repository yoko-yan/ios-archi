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
        GetSeedUseCaseImpl().execute(image: image)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Finish.")
                case let .failure(error):
                    print(error.localizedDescription)
                }
            }, receiveValue: { [weak self] seed in
                guard let self else { return }
                uiState.input.seed = seed
            })
            .store(in: &cancellables)

//        let repository = SeedRepository()
//        repository.get(image: image)
//            .receive(on: DispatchQueue.main)
//            .sink(receiveCompletion: { completion in
//                switch completion {
//                case .finished:
//                    print("Finish.")
//                case let .failure(error):
//                    print(error.localizedDescription)
//                }
//            }, receiveValue: { [weak self] seed in
//                guard let self else { return }
//                uiState.input.seed = seed
//            })
//            .store(in: &cancellables)

//        let repository = SeedRepository()
//        repository.get(image: image) { [weak self] result in
//            guard let self else { return }
//            switch result {
//            case let .success(seed):
//                uiState.input.seed = seed
//            case let .failure(error):
//                print(error.localizedDescription)
//            }
//        }
    }

    func getCoordinates(image: UIImage) {
        let repository = CoordinatesRepository()
        repository.get(image: image)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Finish.")
                case let .failure(error):
                    print(error.localizedDescription)
                }
            }, receiveValue: { [weak self] coordinates in
                guard let self else { return }
                uiState.input.coordinates = coordinates
            })
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

    func saveImage() async {
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

    func loadImage() async {
        uiState.coordinatesImage = ImageRepository().load(fileName: uiState.input.coordinatesImageName)
        uiState.seedImage = ImageRepository().load(fileName: uiState.input.seedImageName)
    }

    func insertOrUpdate() async {
        do {
            switch uiState.editMode {
            case .add:
                try await ItemRepository().insert(item: createItem())
            case .update:
                Task {
                    try await ItemRepository().update(item: createItem())
                }
            }
        } catch {
            print(error)
        }
    }

    func delete() {
        guard case .update = uiState.editMode, let item = uiState.editMode.item else { return }
        Task {
            try await ItemRepository().delete(item: item)
        }
    }
}
