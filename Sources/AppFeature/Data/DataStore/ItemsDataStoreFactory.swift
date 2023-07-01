//
//  ItemsDataStoreFactory.swift
//
//
//  Created by takayuki.yokoda on 2023/07/02.
//

import Foundation

struct ItemsDataStoreFactory {
    static func createItemsDataStore() -> ItemsDataStore {
        ItemsDataStoreInStorage()
    }
}
