import SwiftUI

struct CheckboxStyle: ToggleStyle {
    @Environment(\.colorScheme) private var colorScheme

    func makeBody(configuration: Configuration) -> some View {
        // チェックボックスの外観と動作を返す
        HStack {
            Image(systemName: configuration.isOn ? "checkmark.square" :
                "square")
                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
            configuration.label
        }
        .onTapGesture {
            configuration.isOn.toggle()
        }
    }
}
