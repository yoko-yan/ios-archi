//
//  File.swift
//
//
//  Created by takayuki.yokoda on 2023/07/02.
//

import Foundation

struct ItemEntity: Identifiable, Codable {
    struct Seed: RawRepresentable, Codable {
        var rawValue: Int
    }

    struct Coordinates: Codable {
        let x: Int
        let y: Int
        let z: Int
    }

    var id: String
    var seed: Seed?
    var coordinates: Coordinates?
}
