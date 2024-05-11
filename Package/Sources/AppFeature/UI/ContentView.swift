import SwiftUI

enum TabItem: String, CaseIterable {
    case home
    case photo
    case world

    var name: String {
        switch self {
        case .home:
            return String(localized: "TabItem.Name.Home", bundle: .module)
        case .photo:
            return String(localized: "TabItem.Name.Photo", bundle: .module)
        case .world:
            return String(localized: "TabItem.Name.World", bundle: .module)
        }
    }

    var icon: String {
        switch self {
        case .home:
            return "house"
        case .photo:
            return "photo.stack"
        case .world:
            return "globe.desk"
        }
    }
}

struct ContentView: View {
    @State private var selected: TabItem = .home
    @State private var fadeInOut = true

    var body: some View {
        ZStack {
            TabView(selection: $selected) {
                HomeView()
                    .tabItem {
                        Label(TabItem.home.name, systemImage: TabItem.home.icon)
                    }
                    .tag(TabItem.home)

                PhotoView()
                    .tabItem {
                        Label(TabItem.photo.name, systemImage: TabItem.photo.icon)
                    }
                    .tag(TabItem.photo)

                ListView()
                    .tabItem {
                        Label(TabItem.world.name, systemImage: TabItem.world.icon)
                    }
                    .tag(TabItem.world)
            }
            SplashView()
                .onAppear {
                    withAnimation(
                        Animation.easeIn(duration: 0.3)
                    ) {
                        fadeInOut.toggle()
                    }
                }
                .opacity(fadeInOut ? 1 : 0)
        }
        .tint(.primary)
    }
}

#Preview {
    ContentView()
}
