import SwiftUI

struct ListView: View {
    @State private var navigatePath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigatePath) {
            WorldListView(navigatePath: $navigatePath)
        }
        .analyticsScreen(name: "ListView", class: String(describing: type(of: self)))
    }
}

// MARK: - Previews

#Preview {
    ListView()
}
