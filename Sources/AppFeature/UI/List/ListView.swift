//
//  Created by takayuki.yokoda on 2023/07/01.
//

import SwiftUI

struct ListView: View {
    @State private var navigatePath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigatePath) {
            WorldListView(navigatePath: $navigatePath)
        }
    }
}

// MARK: - Previews

#Preview {
    ListView()
}
