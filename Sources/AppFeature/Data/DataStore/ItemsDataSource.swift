//
//  ItemsDataSource.swift
//
//
//  Created by takayuki.yokoda on 2023/07/02.
//

import Foundation

protocol ItemsDataSource {
    func save(items: [Item])
    func load() -> [Item]
}
