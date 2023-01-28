//
//  HomeViewState.swift
//  ios-archi
//
//  Created by yokoda.takayuki on 2023/01/28.
//

import Foundation

struct HomeViewState: Equatable {
    var seed: Seed = .init(rawValue: 0)
    var seedText: String {
        seed.rawValue == 0 ? "" : String(seed.rawValue)
    }
    var position: Position = .zero
    var positionText: String {
        "\(position.x), \(position.y), \(position.z)"
    }
}
