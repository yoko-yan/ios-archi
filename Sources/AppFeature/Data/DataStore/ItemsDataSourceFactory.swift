//
//  ItemsDataSourceFactory.swift
//
//
//  Created by takayuki.yokoda on 2023/07/02.
//

import Foundation

struct ItemsDataSourceFactory {
    static func createItemsDataStore() -> ItemsDataSource {
        ItemsLocalDataSource()
    }
}
