//
//  ItemsDataStore.swift
//
//
//  Created by takayuki.yokoda on 2023/07/02.
//

import Foundation

protocol ItemsDataStore {
    func save(items: [ItemEntity])
    func load() -> [ItemEntity]
}
