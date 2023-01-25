//
//  ContentView.swift
//  ios-archi
//
//  Created by yokoda.takayuki on 2022/11/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
//        Text("Hello, world!")
        CameraView()
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
