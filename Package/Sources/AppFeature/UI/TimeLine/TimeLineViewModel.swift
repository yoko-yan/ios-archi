import Core
import Observation

// MARK: - Action

enum TimeLineViewAction {
    case load
    case reload
}

// MARK: - View model

@MainActor
@Observable
final class TimeLineViewModel {
    @ObservationIgnored
    @Injected(\.itemsRepository) private var itemsRepository

    private(set) var uiState = TimeLineUiState()

    init(uiState: TimeLineUiState = TimeLineUiState()) {
        self.uiState = uiState
    }

    func send(action: TimeLineViewAction) async {
        switch action {
        case .load:
            do {
                uiState.items = try await itemsRepository.fetchWithoutNoPhoto()
            } catch {
                print(error)
            }
        case .reload:
            await send(action: .load)
        }
    }

    func loadImage(item: Item) {
        guard let imageName = item.spotImageName else { return }
        Task {
            uiState.spotImages[item.id] = try await LoadSpotImageUseCaseImpl().execute(fileName: imageName)
                .map { SpotImage(imageName: nil, image: $0) }
        }
    }
}
