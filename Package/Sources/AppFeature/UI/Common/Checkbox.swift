import SwiftUI

struct Checkbox: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var isChecked = false
    let label: LocalizedStringKey
    var action: ((Bool) -> Void)?

    var body: some View {
        Toggle(isOn: $isChecked) {
            Text(label, bundle: .module)
                .font(.caption)
                .bold()
                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                .padding(.vertical, 12)
        }
        .onChange(of: isChecked) {
            action?(isChecked)
        }
        .toggleStyle(CheckboxStyle())
    }
}

// MARK: - Previews

#if DEBUG
@available(iOS 17.0, *)
#Preview(traits: .fixedLayout(width: 375, height: 40)) {
    Checkbox(label: "Display only items with images")
}
#endif
