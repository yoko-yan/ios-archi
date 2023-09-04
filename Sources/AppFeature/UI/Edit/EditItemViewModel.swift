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
        Task {
            do {
                let seed = try await GetSeedUseCaseImpl().execute(image: image)
                uiState.input.seed = seed
            } catch {
                print(error)
            }
        }

//        GetSeedUseCaseImpl().execute(image: image)
//            .receive(on: DispatchQueue.main)
//            .sink(receiveCompletion: { completion in
//                switch completion {
//                case .finished:
//                    print("Finish.")
//                case let .failure(error):
//                    print(error)
//                }
//            }, receiveValue: { [weak self] seed in
//                guard let self else { return }
//                uiState.input.seed = seed
//            })
//            .store(in: &cancellables)
    }

    func getCoordinates(image: UIImage) {
        Task {
            do {
                let coordinates = try await GetCoordinatesUseCaseImpl().execute(image: image)
                uiState.input.coordinates = coordinates
            } catch {
                print(error)
            }
        }
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
                try await ItemRepository().insert(item: uiState.editItem)
            case .update:
                Task {
                    try await ItemRepository().update(item: uiState.editItem)
                }
            }
        } catch {
            print(error)
        }
    }

    func delete() async {
        guard case .update = uiState.editMode, let item = uiState.editMode.item else { return }
        Task {
            try await ItemRepository().delete(item: item)
        }
    }
}
