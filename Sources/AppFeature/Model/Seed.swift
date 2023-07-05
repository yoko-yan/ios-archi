//
//  Created by takayuki.yokoda on 2023/01/29.
//

import Foundation

struct Seed: RawRepresentable, Hashable, Codable {
    public static var zero: Self { .init(rawValue: 0)! }

    var rawValue: Int

    var text: String {
        String(rawValue)
    }

    /** シード値の範囲
     統合版の範囲：-2147483648～2147483647
     Java版範囲：-9223372036854775808～9223372036854775807
     ref: [https://minecraft.fandom.com/ja/wiki/シード値](https://minecraft.fandom.com/ja/wiki/%E3%82%B7%E3%83%BC%E3%83%89%E5%80%A4)
      */
    init?(rawValue: Int) {
        if -9223372036854775808...9223372036854775807 ~= rawValue {
            self.rawValue = rawValue
            return
        }
        return nil
    }

    init?(_ value: String) {
        guard let value = Int(value) else { return nil }
        self.init(rawValue: value)
    }
}
