//
//  ListView.swift
//  
//
//  Created by takayuki.yokoda on 2023/07/01.
//

import SwiftUI

struct ListView: View {
    let items = [
        Item(seed: .zero, coordinates: .zero),
        Item(seed: nil, coordinates: nil),
        Item(
            seed: Seed(rawValue: 500),
            coordinates: Coordinates(x: 100, y: 20, z: 300)
        )
    ]

    var body: some View {
        NavigationView {
            List(items) { item in
                NavigationLink(destination: DetailView(item: item)) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("seed: \(item.seed?.text ?? "")")
                            Text("coordinates: \(item.coordinates?.text ?? "")")
                        }
                    }
                }
            }
        }
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
    }
}
