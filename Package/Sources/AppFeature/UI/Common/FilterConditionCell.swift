import SwiftUI

struct FilterConditionCell: View {
    let label: LocalizedStringKey
    @Binding var isChecked: Bool
    var action: ((Bool) -> Void)?

    init(
        label: LocalizedStringKey,
        isChecked: Binding<Bool> = .constant(true),
        action: ((Bool) -> Void)? = nil
    ) {
        self.label = label
        _isChecked = isChecked
        self.action = action
    }

    var body: some View {
        HStack {
            Checkbox(label: label, isChecked: $isChecked, action: action)
            Spacer()
        }
        .padding(.horizontal)
    }
}

// MARK: - Previews

#if DEBUG
@available(iOS 17.0, *)
#Preview(traits: .sizeThatFitsLayout) {
    FilterConditionCell(label: "Display only items with images")
}
#endif
