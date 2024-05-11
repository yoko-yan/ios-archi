import Core
import Observation

// MARK: - View model

@MainActor
@Observable
final class RootViewModel {
    @ObservationIgnored
    @Injected(\.synchronizeWithCloudUseCase) private var synchronizeWithCloud

    private(set) var uiState = RootUiState()

    func load() async {
        do {
            try await synchronizeWithCloud.execute()
            uiState.isLaunching = false
        } catch {
            print(error)
            uiState.isLaunching = false
        }
    }
}
