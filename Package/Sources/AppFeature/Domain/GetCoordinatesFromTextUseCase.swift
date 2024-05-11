import Dependencies
import RegexBuilder

protocol GetCoordinatesFromTextUseCase: Sendable {
    func execute(text: String) async -> Coordinates?
}

struct GetCoordinatesFromTextUseCaseImpl: GetCoordinatesFromTextUseCase {
    func execute(text: String) async -> Coordinates? {
        let regex = Regex {
            TryCapture {
                Optionally("-")
                Repeat(.digit, 1...4)
            } transform: {
                Int($0)
            }
            Repeat(Optionally(.whitespace), 1...2)
            ChoiceOf {
                ","
                "."
            }
            Repeat(Optionally(.whitespace), 1...2)
            TryCapture {
                Optionally("-")
                Repeat(.digit, 1...4)
            } transform: {
                Int($0)
            }
            Repeat(Optionally(.whitespace), 1...2)
            ChoiceOf {
                ","
                "."
            }
            Repeat(Optionally(.whitespace), 1...2)
            TryCapture {
                Optionally("-")
                Repeat(.digit, 1...4)
            } transform: {
                Int($0)
            }
        }

        if let match = text.firstMatch(of: regex) {
            let (_, x, y, z) = match.output
            return Coordinates(x: x, y: y, z: z)
        }
        return nil
    }
}

struct GetCoordinatesFromTextUseCaseKey: DependencyKey {
    static let liveValue: any GetCoordinatesFromTextUseCase = GetCoordinatesFromTextUseCaseImpl()
}

extension DependencyValues {
    var getCoordinatesFromTextUseCase: any GetCoordinatesFromTextUseCase {
        get { self[GetCoordinatesFromTextUseCaseKey.self] }
        set { self[GetCoordinatesFromTextUseCaseKey.self] = newValue }
    }
}
