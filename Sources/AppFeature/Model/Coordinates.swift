//
//  Created by yoko-yan on 2023/01/28.
//

import Foundation
import RegexBuilder

struct Coordinates: Hashable {
    public static var zero: Self { .init(x: 0, y: 0, z: 0)! } // swiftlint:disable:this force_unwrapping
    public static let regex = Regex {
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

    var text: String {
        "\(x), \(y), \(z)"
    }

    let x: Int
    let y: Int
    let z: Int

    init?(x: Int, y: Int, z: Int) {
        self.init("\(x),\(y),\(z)")
    }

    init?(_ value: String) {
        if let match = value.firstMatch(of: Self.regex) {
            let (_, x, y, z) = match.output
            self.x = x
            self.y = y
            self.z = z
            return
        }
        return nil
    }
}
