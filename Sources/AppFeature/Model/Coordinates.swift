//
//  Created by yoko-yan on 2023/01/28.
//

import Foundation
import RegexBuilder

struct Coordinates: Hashable {
    public static var zero: Self { .init(x: 0, y: 0, z: 0)! } // swiftlint:disable:this force_unwrapping

    var text: String {
        "\(x),\(y),\(z)"
    }

    var textWitWhitespaces: String {
        "\(x), \(y), \(z)"
    }

    let x: Int
    let y: Int
    let z: Int

    init?(x: Int, y: Int, z: Int) {
        guard case -30000000...30000000 = x else { return nil }
        guard case -64...320 = y else { return nil }
        guard case -30000000...30000000 = z else { return nil }
        self.x = x
        self.y = y
        self.z = z
    }

    init?(_ text: String) {
        let xyz = text.components(separatedBy: ",")
        guard xyz.count >= 3 else { return nil }
        let x = xyz[0].trimmingCharacters(in: .whitespaces)
        let y = xyz[1].trimmingCharacters(in: .whitespaces)
        let z = xyz[2].trimmingCharacters(in: .whitespaces)
        if let ix = Int(x),
           let iy = Int(y),
           let iz = Int(z)
        {
            self.init(x: ix, y: iy, z: iz)
        }
        return nil
    }
}
