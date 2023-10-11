//
//  Created by yokoda.takayuki on 2023/01/30.
//

import SwiftUI

struct OutlineButtonStyle: ButtonStyle {
    var color: Color = .gray

    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .foregroundColor(color)
            .background(
                RoundedRectangle(
                    cornerRadius: 8,
                    style: .continuous
                ).stroke(color)
            )
    }
}
