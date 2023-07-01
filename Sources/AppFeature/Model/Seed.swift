//
//  Seed.swift
//  ios-archi
//
//  Created by takayuki.yokoda on 2023/01/29.
//

import Foundation

struct Seed: Equatable, RawRepresentable {
    public static var zero: Self { .init(rawValue: 0) }

    var rawValue: Int

    var text: String {
        String(rawValue)
    }
}

extension Seed: Translator {
    static func translate(_ entity: ItemEntity.Seed?) -> Self? {
        guard let entity else { return nil }
        return Self(rawValue: entity.rawValue)
    }
}

extension ItemEntity.Seed: Translator {
    static func translate(_ model: Seed?) -> Self? {
        guard let model else { return nil }
        return Self(rawValue: model.rawValue)
    }
}
