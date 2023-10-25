//
//  Created by yoko-yan on 2023/10/25
//

import SwiftUI

enum TabItem: String, CaseIterable {
    case home
    case photo
    case list

    var name: String {
        switch self {
        case .home:
            return "ホーム"

        case .photo:
            return "スポット"

        case .list:
            return "ワールド"
        }
    }

    var icon: String {
        switch self {
        case .home:
            return "house"

        case .photo:
            return "photo.stack"

        case .list:
            return "list.bullet"
        }
    }
}

struct ContentView: View {
    @State private var selected: TabItem = .home

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
                        Label(TabItem.list.name, systemImage: TabItem.list.icon)
                    }
                    .tag(TabItem.list)
            }
        }
        .tint(.primary)
    }
}

#Preview {
    ContentView()
}
