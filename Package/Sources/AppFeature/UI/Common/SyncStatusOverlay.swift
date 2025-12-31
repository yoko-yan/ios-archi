import SwiftUI

// MARK: - SyncStatusOverlay

struct SyncStatusOverlay: View {
    let syncState: SyncState
    @State private var isVisible = true

    var body: some View {
        Group {
            switch syncState {
            case .idle:
                EmptyView()
            case .syncing:
                SyncingBanner()
            case .completed:
                EmptyView()
            case .failed:
                SyncFailedBanner()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: syncState)
        .onChange(of: syncState) { _, newState in
            if case .completed = newState {
                // 同期完了後は表示不要
                isVisible = false
            } else if case .failed = newState {
                // 失敗時は3秒後に自動で非表示
                Task {
                    try? await Task.sleep(for: .seconds(3))
                    isVisible = false
                }
            } else {
                isVisible = true
            }
        }
    }
}

// MARK: - SyncingBanner

private struct SyncingBanner: View {
    var body: some View {
        HStack(spacing: 8) {
            ProgressView()
                .scaleEffect(0.7)
            Text("同期中...")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.top, 8)
    }
}

// MARK: - SyncFailedBanner

private struct SyncFailedBanner: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
            Text("同期できませんでした")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.top, 8)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        SyncStatusOverlay(syncState: .syncing)
        SyncStatusOverlay(syncState: .failed("Error"))
        SyncStatusOverlay(syncState: .completed)
        SyncStatusOverlay(syncState: .idle)
    }
}
