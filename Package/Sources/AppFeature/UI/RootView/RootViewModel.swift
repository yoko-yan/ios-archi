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
            try await Task.sleep(for: .seconds(2))
            defer {
                uiState.isLaunching = false
            }
            try await synchronizeWithCloud.execute()
        } catch {
            print(error)
        }
    }
}
