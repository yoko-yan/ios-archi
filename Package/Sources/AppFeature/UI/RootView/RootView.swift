import SwiftData
import SwiftUI

@MainActor
public struct RootView: View {
    @State private var viewModel = RootViewModel()
    @Environment(\.scenePhase) private var scenePhase

    public var body: some View {
        Group {
            if viewModel.uiState.isLaunching {
                SplashView()
            } else {
                ContentView()
                    .overlay(alignment: .top) {
                        SyncStatusOverlay(syncState: viewModel.uiState.syncState)
                    }
            }
        }
        .task {
            await viewModel.load()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                // フォアグラウンド復帰時に設定変更をチェック
                SwiftDataManager.shared.reinitializeIfNeeded()
            }
        }
        .modelContainer(SwiftDataManager.shared.container)
    }

    public init() {}
}

// MARK: - Previews

#Preview {
    RootView()
}
