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
            uiState.isLaunching = try await synchronizeWithCloud.execute()
        } catch {
            print(error)
            uiState.isLaunching = false
        }
    }
}
