//
//  Created by yokoda.takayuki on 2023/01/25.
//

import Core
import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            TimeLineView()
        }
        .analyticsScreen(name: "HomeView", class: String(describing: type(of: self)))
    }
}

// MARK: - Previews

#Preview {
    HomeView()
}
