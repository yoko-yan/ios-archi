import Observation

// MARK: - View model

@MainActor
@Observable
final class WorldDetailViewModel {
    private(set) var uiState: WorldDetailUiState

    init(world: World) {
        uiState = WorldDetailUiState(world: world)
    }

    func reload(world: World) {
        uiState.world = world
    }
}
