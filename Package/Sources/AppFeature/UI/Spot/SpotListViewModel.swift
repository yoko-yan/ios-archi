import Dependencies
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
    @Dependency(\.itemsRepository) private var itemsRepository
    @ObservationIgnored
    @Dependency(\.loadSpotImageUseCase) private var loadSpotImageUseCase

    private(set) var uiState = SpotListUiState()

    init(uiState: SpotListUiState = .init()) {
        self.uiState = uiState
    }

    var isChecked: Bool {
        get { uiState.isChecked }
        set { uiState.isChecked = newValue }
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
        if let spotImage = uiState.spotImages[item.id] ?? nil,
           spotImage.isLoading || spotImage.image != nil
        {
            return
        }

        uiState.spotImages[item.id] = SpotImage(imageName: nil, image: nil, isLoading: true)
        Task {
            let image = try await loadSpotImageUseCase.execute(fileName: imageName)
            uiState.spotImages[item.id] = SpotImage(imageName: nil, image: image, isLoading: false)
        }
    }
}
