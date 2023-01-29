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
    @Published private(set) var state = HomeViewState()

    private var cancellables: Set<AnyCancellable> = []

    func clearSeed() {
        state.seed = .zero
    }

    func clearPosition() {
        state.position = .zero
    }

    func getSeed(image: UIImage) {
        let repository = SeedRepository()
        repository.get(image: image)
            .sink { [weak self] seed in
                self?.state.seed = Seed(rawValue: Int(seed)!)
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
                    self?.state.position = Position(x: x, y: y, z: z)
                }
            }
            .store(in: &cancellables)
    }
}
