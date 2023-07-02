//
//  HomeView.swift
//  ios-archi
//
//  Created by yokoda.takayuki on 2023/01/25.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        TabView {
            DetailView(item: Item(seed: .zero, coordinates: .zero))
                .tabItem {
                    Image(systemName: "house")
                        .accentColor(.gray)
                }
            ListView()
                .tabItem {
                    Image(systemName: "plus")
                }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
