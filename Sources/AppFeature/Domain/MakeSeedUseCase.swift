//
//  Created by apla on 2023/09/06
//

import Combine
import Dependencies
import Foundation
import RegexBuilder

protocol MakeSeedUseCase: Sendable {
    func execute(text: String) async -> Seed?
}

struct MakeSeedUseCaseImpl: MakeSeedUseCase {
    func execute(text: String) async -> Seed? {
        let regex = Regex {
            Capture {
                Optionally("-")
                OneOrMore(.digit)
            } transform: { String($0) }
        }

        let matches = text.matches(of: regex).map(\.output.1)
        // シードに変換可能（取りうる値の範囲内）のみの数字に絞る
        let filterdTexs = matches.filter { Seed($0) != nil }
        // 読み取れた数字が複数ある場合は、マイナスの値も含めてrより桁数が大きい数字をSeedにする
        guard let max = filterdTexs.max(by: { a, b -> Bool in
            a.count < b.count
        }) else { return nil }
        return Seed(max)
    }
}

struct MakeSeedUseCaseKey: DependencyKey {
    static let liveValue: any MakeSeedUseCase = MakeSeedUseCaseImpl()
}

extension DependencyValues {
    var makeSeedUseCase: any MakeSeedUseCase {
        get { self[MakeSeedUseCaseKey.self] }
        set { self[MakeSeedUseCaseKey.self] = newValue }
    }
}
