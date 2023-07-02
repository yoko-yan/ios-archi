//
//  HomeView.swift
//  ios-archi
//
//  Created by yokoda.takayuki on 2023/01/25.
//

import SwiftUI

struct HomeView: View {
    @State private var isShowDetailView = false

    var body: some View {
        ZStack {
            ListView()

            FloatingButton(action: {
                isShowDetailView.toggle()
            }, label: {
                Image(systemName: "pencil")
                    .foregroundColor(.white)
                    .font(.system(size: 24))
            })
        }
        .fullScreenCover(isPresented: $isShowDetailView) {
            AddItemView()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
