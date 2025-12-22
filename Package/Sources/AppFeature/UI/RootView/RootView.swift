import SwiftData
import SwiftUI

@MainActor
public struct RootView: View {
    @State private var viewModel = RootViewModel()

    public var body: some View {
        Group {
            if viewModel.uiState.isLaunching {
                SplashView()
            } else {
                ContentView()
            }
        }
        .task {
            await viewModel.load()
        }
        .modelContainer(SwiftDataManager.shared.container)
    }

    public init() {}
}

// MARK: - Previews

#Preview {
    RootView()
}
