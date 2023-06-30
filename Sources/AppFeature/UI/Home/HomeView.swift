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
            ListView()
                .tabItem {
                    Image(systemName: "1.circle.fill")
                }
            DetailView(item: Item(seed: .zero, coordinates: .zero))
                .tabItem {
                    Image(systemName: "2.circle.fill")
                }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
