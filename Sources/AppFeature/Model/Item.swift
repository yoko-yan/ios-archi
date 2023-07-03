//
//  Item.swift
//
//
//  Created by takayuki.yokoda on 2023/07/01.
//

import Foundation

struct Item: Identifiable, Hashable, Codable {
    var id: String
    var coordinates: Coordinates?
    var seed: Seed?
    var coordinatesImageName: String?
    var seedImageName: String?
    var createdAt: Date?
    var updatedAt: Date?
}
