//
//  Created by yokoda.takayuki on 2023/07/05
//

import SwiftUI

struct RoundedButtonStyle: ButtonStyle {
    var color: Color = .gray
    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .accentColor(.white)
            .foregroundColor(configuration.isPressed ? .gray : .accentColor)
            .background(color)
            .cornerRadius(8)
    }
}
