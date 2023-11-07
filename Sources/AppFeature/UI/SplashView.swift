//
//  Created by yoko-yan on 2023/10/29
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            Color.white
            Image(.icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding()
        }
    }
}

#Preview {
    SplashView()
}
