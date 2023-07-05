//
//  Created by yokoda.takayuki on 2023/07/05
//

import SwiftUI

struct RoundedButtonStyle: ButtonStyle {
    var color: Color = .gray
    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .foregroundColor(.white)
            .background(color)
            .cornerRadius(8)
    }
}
