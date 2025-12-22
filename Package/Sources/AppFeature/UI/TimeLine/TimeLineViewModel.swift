import Dependencies
import Observation

// MARK: - Action

enum TimeLineViewAction {
    case load
    case reload
    case isChecked(Bool)
}

// MARK: - View model

@MainActor
@Observable
final class TimeLineViewModel {
    @ObservationIgnored
    @Dependency(\.itemsRepository) private var itemsRepository

    private(set) var uiState = TimeLineUiState()

    init(uiState: TimeLineUiState = TimeLineUiState()) {
        self.uiState = uiState
    }

    var isChecked: Bool {
        get { uiState.isChecked }
        set { uiState.isChecked = newValue }
    }

    func send(action: TimeLineViewAction) async {
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
            uiState.spotImages[item.id] = try await LoadSpotImageUseCaseImpl().execute(fileName: imageName)
                .map { SpotImage(imageName: nil, image: $0) }
        }
    }
}
