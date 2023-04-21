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
                if !seed.isEmpty {
                    self?.uiState.seed = Seed(rawValue: Int(seed)!)
                    return
                }
                self?.uiState.seed = nil
            }
            .store(in: &cancellables)
    }

    func getPosition(image: UIImage) {
        let repository = PositionRepository()
        repository.get(image: image)
            .sink { [weak self] position in
                let arr = position.components(separatedBy: ",")
                if arr.count >= 3 {
                    let x = Int(arr[0].trimmingCharacters(in: .whitespaces))!
                    let y = Int(arr[1].trimmingCharacters(in: .whitespaces))!
                    let z = Int(arr[2].trimmingCharacters(in: .whitespaces))!
                    self?.uiState.position = Position(x: x, y: y, z: z)
                    return
                }
                self?.uiState.position = nil
            }
            .store(in: &cancellables)
    }
}
