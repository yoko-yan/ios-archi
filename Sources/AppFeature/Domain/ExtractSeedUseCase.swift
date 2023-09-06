//
//  Created by apla on 2023/09/06
//

import Combine
import Dependencies
import Foundation
import RegexBuilder

protocol ExtractSeedUseCase: Sendable {
    func execute(texts: [String]) async -> Seed?
}

struct ExtractSeedUseCaseImpl: ExtractSeedUseCase {
    func execute(texts: [String]) async -> Seed? {
        let regex = Regex {
            Capture {
                Optionally("-")
                OneOrMore(.digit)
            } transform: { String($0) }
        }

        // シード値に余計な文字がついてしまったケースを考慮し、読み取れた文字を１つの文字列にして、シード値の形式にマッチするものをSeedにする
        let text = texts.joined(separator: " ")

        // シードに変換可能（取りうる値の範囲内）のみの数字に絞って抽出
        let matches = text.matches(of: regex).compactMap { Seed($0.output.1) }
        // 読み取れた数字が複数ある場合は、マイナスの値も含めてより桁数が大きい数字をSeedにする
        guard let seed = matches.max(by: { a, b -> Bool in
            a.text.count < b.text.count
        }) else { return nil }
        return seed
    }
}

struct ExtractSeedUseCaseKey: DependencyKey {
    static let liveValue: any ExtractSeedUseCase = ExtractSeedUseCaseImpl()
}

extension DependencyValues {
    var extractSeedUseCase: any ExtractSeedUseCase {
        get { self[ExtractSeedUseCaseKey.self] }
        set { self[ExtractSeedUseCaseKey.self] = newValue }
    }
}
