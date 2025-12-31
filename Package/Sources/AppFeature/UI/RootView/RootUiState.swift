import Foundation

// MARK: - SyncState

enum SyncState: Equatable {
    case idle
    case syncing
    case completed
    case failed(String)

    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.syncing, .syncing), (.completed, .completed):
            return true
        case let (.failed(lhsMessage), .failed(rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
}

// MARK: - RootUiState

struct RootUiState: Equatable {
    var isLaunching = true
    var syncState: SyncState = .idle
    var lastSyncedAt: Date?
}
