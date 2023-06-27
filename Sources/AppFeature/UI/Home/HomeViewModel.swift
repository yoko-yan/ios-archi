//
//  HomeViewModel.swift
//  ios-archi
//
//  Created by yokoda.takayuki on 2023/01/28.
//

import Combine
import UIKit

@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var uiState = HomeViewUiState()

    private var cancellables: Set<AnyCancellable> = []

    func clearSeed() {
        uiState.seed = nil
    }

    func clearPosition() {
        uiState.position = nil
    }

    func getSeed(image: UIImage) {
        let repository = SeedRepository()
        repository.get(image: image)
            .sink { [weak self] seed in
                guard let self else { return }
                if !seed.isEmpty, let seedValue = Int(seed) {
                    uiState.seed = Seed(rawValue: seedValue)
                    return
                }
            }
            .store(in: &cancellables)
    }

    func getPosition(image: UIImage) {
        let repository = PositionRepository()
        repository.get(image: image)
            .sink { [weak self] position in
                guard let self else { return }
                let arr = position.components(separatedBy: ",")
                if arr.count >= 3,
                   let x = Int(arr[0].trimmingCharacters(in: .whitespaces)),
                   let y = Int(arr[1].trimmingCharacters(in: .whitespaces)),
                   let z = Int(arr[2].trimmingCharacters(in: .whitespaces))
                {
                    uiState.position = Position(x: x, y: y, z: z)
                    return
                }
                uiState.position = nil
            }
            .store(in: &cancellables)
    }
}
