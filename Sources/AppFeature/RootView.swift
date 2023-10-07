//
//  Created by yokoda.takayuki on 2022/11/23.
//

import SwiftUI

enum TabItem: String, CaseIterable {
    case home
    case list

    var name: String {
        switch self {
        case .home:
            return "ホーム"

        case .list:
            return "リスト"
        }
    }

    var icon: String {
        switch self {
        case .home:
            return "house"

        case .list:
            return "list.bullet"
        }
    }
}

public struct RootView: View {
    @State private var selected: TabItem = .home

    public var body: some View {
        ZStack {
            TabView(selection: $selected) {
                HomeView()
                    .tabItem {
                        Label(TabItem.home.name, systemImage: TabItem.home.icon)
                    }
                    .tag(TabItem.home)

                ListView()
                    .tabItem {
                        Label(TabItem.list.name, systemImage: TabItem.list.icon)
                    }
                    .tag(TabItem.list)
            }
        }
        .tint(.primary)
    }

    public init() {}
}

#Preview {
    RootView()
}
