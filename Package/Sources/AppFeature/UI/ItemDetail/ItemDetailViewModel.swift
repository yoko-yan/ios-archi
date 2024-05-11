import Observation

// MARK: - View model

@MainActor
@Observable
final class ItemDetailViewModel {
    private(set) var uiState: ItemDetailUiState

    init(item: Item) {
        uiState = ItemDetailUiState(item: item)
    }

    func loadImage() {
        print(uiState.item)
        Task {
            uiState.spotImage = try await LoadSpotImageUseCaseImpl().execute(fileName: uiState.item.spotImageName ?? "")
        }
    }

    func reload(item: Item) {
        uiState.item = item
        loadImage()
    }
}
