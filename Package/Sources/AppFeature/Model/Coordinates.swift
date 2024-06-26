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
        guard case -64...3200 = y else { return nil }
        guard case -30000000...30000000 = z else { return nil }
        self.x = x
        self.y = y
        self.z = z
    }

    init?(_ text: String) {
        let xyz = text.components(separatedBy: ",")
        guard xyz.count >= 3 else { return nil }
        if let x = Int(xyz[0]),
           let y = Int(xyz[1]),
           let z = Int(xyz[2])
        {
            self.init(x: x, y: y, z: z)
        }
        return nil
    }
}
