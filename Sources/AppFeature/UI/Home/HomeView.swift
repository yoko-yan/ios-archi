//
//  Created by yokoda.takayuki on 2023/01/25.
//

import Core
import SwiftUI

struct HomeView: View {
    @State private var isShowAppInfoView = false

    var body: some View {
        NavigationStack {
            TimeLineView()
                .navigationBarItems(
                    trailing: Button(action: {
                        isShowAppInfoView.toggle()
                    }) {
                        Image(systemName: "info.circle.fill")
                    }
                )
        }
        .sheet(isPresented: $isShowAppInfoView) {
            AppInfoView()
        }
        .analyticsScreen(name: "HomeView", class: String(describing: type(of: self)))
    }
}

// MARK: - Previews

#Preview {
    HomeView()
}
