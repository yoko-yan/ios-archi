//
//  Created by apla on 2023/10/08
//

import SwiftUI

struct WorldDetailView: View {
    @Binding var navigatePath: NavigationPath

    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .onTapGesture {
                navigatePath.removeLast()
            }
    }
}

// #Preview {
//    WorldDetailView()
// }
