//
//  Created by takayuki.yokoda on 2023/07/02.
//

import SwiftUI

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.white)
            .clipped()
            .shadow(color: .gray, radius: 3, x: 3, y: 3)
            .accessibilityElement()
    }
}
