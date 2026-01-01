import SwiftUI

struct CardStyle: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .background(colorScheme == .dark ? Color.black : Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(
                color: Color.black.opacity(colorScheme == .dark ? 0.4 : 0.12),
                radius: 12,
                x: 0,
                y: 6
            )
            .accessibilityElement()
    }
}
