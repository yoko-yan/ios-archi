import Dependencies
import RegexBuilder

protocol GetSeedFromTextUseCase: Sendable {
    func execute(text: String) async -> Seed?
}

struct GetSeedFromTextUseCaseImpl: GetSeedFromTextUseCase {
    func execute(text: String) async -> Seed? {
        let regex = Regex {
            Capture {
                Optionally("-")
                OneOrMore(.digit)
            } transform: {
                String($0)
            }
        }

        // シードに変換可能（取りうる値の範囲内）のみの数字に絞って抽出
        let matches = text.matches(of: regex).compactMap { Seed($0.output.1) }
        // 読み取れた数字が複数ある場合は、マイナスの値も含めてより桁数が大きい数字をSeedにする
        guard let seed = matches.max(by: { a, b -> Bool in
            a.text.count < b.text.count
        }) else { return nil }
        return seed
    }
}

struct GetSeedFromTextUseCaseKey: DependencyKey {
    static let liveValue: any GetSeedFromTextUseCase = GetSeedFromTextUseCaseImpl()
}

extension DependencyValues {
    var getSeedFromTextUseCase: any GetSeedFromTextUseCase {
        get { self[GetSeedFromTextUseCaseKey.self] }
        set { self[GetSeedFromTextUseCaseKey.self] = newValue }
    }
}
