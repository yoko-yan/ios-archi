//
//  Created by yoko-yan on 2023/10/08
//

import Core
import SwiftUI

struct PhotoView: View {
    var body: some View {
        NavigationStack {
            SpotListView()
        }
        .analyticsScreen(name: "PhotoView", class: String(describing: type(of: self)))
    }
}

// MARK: - Previews

#Preview {
    PhotoView()
}
