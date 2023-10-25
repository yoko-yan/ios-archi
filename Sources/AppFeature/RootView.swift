//
//  Created by yokoda.takayuki on 2022/11/23.
//

import SwiftUI

public struct RootView: View {
    @StateObject private var viewModel = RootViewModel()

    public var body: some View {
        if viewModel.uiState.isLaunching {
            ZStack {
                Color("Primary")
                    .ignoresSafeArea() // ステータスバーまで塗り潰すために必要
                Image(.icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
            }
        } else {
            ContentView()
        }
    }

    public init() {}
}

// MARK: - Previews

#Preview {
    RootView()
}
