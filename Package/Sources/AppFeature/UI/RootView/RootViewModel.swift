import Dependencies
import Foundation
import Observation

// MARK: - View model

@MainActor
@Observable
final class RootViewModel {
    @ObservationIgnored
    @Dependency(\.synchronizeWithCloudUseCase) private var synchronizeWithCloud

    private(set) var uiState = RootUiState()
    private var syncTask: Task<Void, Never>?

    func load() async {
        // 即座にスプラッシュを解除して画面表示
        uiState.isLaunching = false

        // バックグラウンドで同期を開始
        startBackgroundSync()
    }

    func retrySync() {
        startBackgroundSync()
    }

    private func startBackgroundSync() {
        syncTask?.cancel()
        syncTask = Task {
            uiState.syncState = .syncing
            do {
                try await synchronizeWithCloud.execute()
                uiState.syncState = .completed
                uiState.lastSyncedAt = Date()
            } catch is CancellationError {
                // キャンセルは無視
            } catch {
                print(error)
                uiState.syncState = .failed(error.localizedDescription)
            }
        }
    }
}
