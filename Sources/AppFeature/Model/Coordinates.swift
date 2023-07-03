//
//  Coordinates.swift
//  ios-archi
//
//  Created by takayuki.yokoda on 2023/01/28.
//

import Foundation

struct Coordinates: Hashable {
    public static var zero: Self { .init(x: 0, y: 0, z: 0) }

    var text: String {
        "\(x), \(y), \(z)"
    }

    let x: Int
    let y: Int
    let z: Int
}
