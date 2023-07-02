//
//  Coordinates.swift
//  ios-archi
//
//  Created by takayuki.yokoda on 2023/01/28.
//

import Foundation

struct Coordinates: Equatable, Hashable {
    public static var zero: Self { .init(x: 0, y: 0, z: 0) }

    var text: String {
        "\(x), \(y), \(z)"
    }

    let x: Int
    let y: Int
    let z: Int
}

extension Coordinates: Translator {
    static func translate(_ entity: ItemEntity.Coordinates?) -> Self? {
        guard let entity else { return nil }
        return Self(x: entity.x, y: entity.y, z: entity.z)
    }
}

extension ItemEntity.Coordinates: Translator {
    static func translate(_ model: Coordinates?) -> Self? {
        guard let model else { return nil }
        return Self(x: model.x, y: model.y, z: model.z)
    }
}
