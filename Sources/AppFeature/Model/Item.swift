//
//  Item.swift
//
//
//  Created by takayuki.yokoda on 2023/07/01.
//

import Foundation

struct Item: Identifiable, Equatable, Hashable {
    var id: String = UUID().uuidString
    var uid: String? // 永続化用のユニークID
    var seed: Seed?
    var coordinates: Coordinates?
}

extension Item: Translator {
    static func translate(_ entity: ItemEntity) -> Self {
        let id = entity.id
        let uid = entity.id
        let seed = Seed.translate(entity.seed)
        let coordinates = Coordinates.translate(entity.coordinates)
        return Self(id: id, uid: uid, seed: seed, coordinates: coordinates)
    }
}

extension ItemEntity: Translator {
    static func translate(_ model: Item) -> Self {
        let id = model.id
        let seed = ItemEntity.Seed.translate(model.seed)
        let coordinates = Coordinates.translate(model.coordinates)
        return Self(id: id, seed: seed, coordinates: coordinates)
    }
}
