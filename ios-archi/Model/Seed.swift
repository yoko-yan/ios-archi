//
//  Seed.swift
//  ios-archi
//
//  Created by takayuki.yokoda on 2023/01/29.
//

import Foundation

struct Seed: Equatable, RawRepresentable {
    var rawValue: Int

    public static var zero: Self { .init(rawValue: 0) }

    var text: String {
        String(rawValue)
    }
}
