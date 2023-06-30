//
//  Item.swift
//
//
//  Created by takayuki.yokoda on 2023/07/01.
//

import Foundation

struct Item: Identifiable, Equatable {
    let id = UUID()
    var seed: Seed?
    var coordinates: Coordinates?
}
