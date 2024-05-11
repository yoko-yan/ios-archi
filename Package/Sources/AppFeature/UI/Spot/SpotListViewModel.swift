import Core
import UIKit

// MARK: - Action

enum SpotViewAction {
    case load
    case reload
    case isChecked(Bool)
}

// MARK: - View model

@MainActor
@Observable
final class SpotListViewModel {
    @ObservationIgnored
    @Injected(\.itemsRepository) private var itemsRepository
    @ObservationIgnored
    @Injected(\.loadSpotImageUseCase) private var loadSpotImageUseCase

    private(set) var uiState = SpotListUiState()

    init(uiState: SpotListUiState = .init()) {
        self.uiState = uiState
    }

    func send(action: SpotViewAction) async {
        switch action {
        case .load:
            do {
                uiState.items = uiState.isChecked ? try await itemsRepository.fetchWithoutNoPhoto() : try await itemsRepository.fetchAll()
            } catch {
                print(error)
            }
        case .reload:
            await send(action: .load)
        case let .isChecked(isChecked):
            uiState.isChecked = isChecked
            await send(action: .load)
        }
    }

    func loadImage(item: Item) {
        guard let imageName = item.spotImageName else { return }
        Task {
            uiState.spotImages[item.id] = try await loadSpotImageUseCase.execute(fileName: imageName).map { SpotImage(imageName: nil, image: $0) }
        }
    }
}
