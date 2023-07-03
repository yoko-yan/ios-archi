//
//  Seed.swift
//  ios-archi
//
//  Created by takayuki.yokoda on 2023/01/29.
//

import Foundation

struct Seed: RawRepresentable, Hashable, Codable {
    public static var zero: Self { .init(rawValue: 0) }

    var rawValue: Int

    var text: String {
        String(rawValue)
    }
}
