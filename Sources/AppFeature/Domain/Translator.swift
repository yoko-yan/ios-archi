//
//  File.swift
//
//
//  Created by takayuki.yokoda on 2023/07/02.
//

import Foundation

protocol Translator {
    associatedtype Input
    associatedtype Output

    static func translate(_: Input) -> Output
}
