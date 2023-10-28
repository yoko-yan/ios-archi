//
//  Created by yokoda.takayuki on 2022/11/23.
//

import SwiftUI

public struct RootView: View {
    @StateObject private var viewModel = RootViewModel()

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
    }

    public init() {}
}

// MARK: - Previews

#Preview {
    RootView()
}
