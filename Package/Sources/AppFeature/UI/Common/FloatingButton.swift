import SwiftUI

struct FloatingButton<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme

    var action: (() -> Void)?
    var accessibilityIdentifier: String = "FloatingButton"
    @ViewBuilder var label: () -> Content

    var body: some View {
        Button(action: {
            action?()
        }, label: {
            label()
        })
        .frame(width: 48, height: 48)
        .background(
            Circle()
                .fill(.green.gradient)
                .shadow(
                    color: Color.green.opacity(0.4),
                    radius: 8,
                    x: 0,
                    y: 4
                )
                .shadow(
                    color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.15),
                    radius: 12,
                    x: 0,
                    y: 6
                )
        )
        .clipShape(Circle())
        .accessibilityIdentifier(accessibilityIdentifier)
    }
}
