import SwiftUI

struct Checkbox: View {
    @Environment(\.colorScheme) private var colorScheme
    @Binding var isChecked: Bool
    let label: LocalizedStringKey
    var action: ((Bool) -> Void)?

    init(
        label: LocalizedStringKey,
        isChecked: Binding<Bool> = .constant(true),
        action: ((Bool) -> Void)? = nil
    ) {
        self.label = label
        self._isChecked = isChecked
        self.action = action
    }
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
