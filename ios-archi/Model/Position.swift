//
//  Position.swift
//  ios-archi
//
//  Created by takayuki.yokoda on 2023/01/28.
//

import Foundation

struct Position: Equatable {
    let x: Int
    let y: Int
    let z: Int

    public static var zero: Self { .init(x: 0, y: 0, z: 0) }
}
