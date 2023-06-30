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

    init(item: Item) {
        uiState = DetailUiState(item: item)
    }

    func clearSeed() {
        uiState.item.seed = nil
    }

    func clearCoordinates() {
        uiState.item.coordinates = nil
    }

    func getSeed(image: UIImage) {
        let repository = SeedRepository()
        repository.get(image: image)
            .sink { [weak self] seed in
                guard let self else { return }
                if !seed.isEmpty, let seedValue = Int(seed) {
                    uiState.item.seed = Seed(rawValue: seedValue)
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
                    uiState.item.coordinates = Coordinates(x: x, y: y, z: z)
                    return
                }
                uiState.item.coordinates = nil
            }
            .store(in: &cancellables)
    }
}
