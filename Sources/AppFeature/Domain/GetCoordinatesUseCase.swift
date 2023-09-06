//
//  Created by yokoda.takayuki on 2023/07/27
//

import Combine
import Foundation
import UIKit

struct GetCoordinatesUseCaseImpl {
    private let recognizeTextRepository: RecognizedTextsRepository
    init(recognizeTextRepository: RecognizedTextsRepository = RecognizedTextsRepositoryImpl()) {
        self.recognizeTextRepository = recognizeTextRepository
    }

    func execute(image: UIImage) async throws -> Coordinates? {
        let texts = try await recognizeTextRepository.get(image: image)
        // 座標が分割して認識されてしまったケースを考慮し、読み取れた文字を１つの文字列にして、座標の形式にマッチするものをCoordinatesにする
        let text = texts.joined(separator: " ")
        let pattern = #"(-?[0-9]{1,4})[,|.][\s]?(-?[0-9]{1,4})[,|.][\s]?(-?[0-9]{1,4})"#
        // swiftlint:disable:next force_try
        let regex = try! NSRegularExpression(pattern: pattern, options: [.allowCommentsAndWhitespace])
        let textNS = NSString(string: text)
        if let matche = regex.firstMatch(in: text, options: [], range: NSRange(0..<text.count)),
           let x = Int(textNS.substring(with: matche.range(at: 1))),
           let y = Int(textNS.substring(with: matche.range(at: 2))),
           let z = Int(textNS.substring(with: matche.range(at: 3)))
        {
            return Coordinates(x: x, y: y, z: z)
        }
        return nil
    }
}
