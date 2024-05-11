import SwiftUI

struct RoundedButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled
    var color: Color = .gray

    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .foregroundColor(.white)
            .background(isEnabled ? color : Color.gray)
            .cornerRadius(8)
    }
}
