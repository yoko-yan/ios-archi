import SwiftUI

struct FilterConditionCell: View {
    let label: LocalizedStringKey
    var action: ((Bool) -> Void)?

    var body: some View {
        HStack {
            Checkbox(label: label, action: action)
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
