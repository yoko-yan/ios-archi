//
//  Created by yokoda.takayuki on 2023/07/27
//

import Combine
import Foundation
import UIKit

struct GetCoordinatesUseCaseImpl {
    private let recognizeTextRepository: RecognizeTextRepository
    init(recognizeTextRepository: RecognizeTextRepository = RecognizeTextRepositoryImpl()) {
        self.recognizeTextRepository = recognizeTextRepository
    }

    func execute(image: UIImage) async throws -> Coordinates? {
        let texts = try await recognizeTextRepository.get(image: image)
        // 座標が分割して認識されてしまったケースを考慮し、読み取れた文字を１つの文字列にして、座標の形式にマッチするものをCoordinatesにする
        let text = texts.joined(separator: " ")
        let pattern = #"(-?[0-9]{1,4},[\s]?-?[0-9]{1,4},[\s]?-?[0-9]{1,4})"#
        // swiftlint:disable:next force_try
        let regex = try! NSRegularExpression(pattern: pattern, options: [.allowCommentsAndWhitespace])
        let matches = regex.matches(in: text, options: [], range: NSRange(0..<text.count))
        if let match = matches.first {
            let range = match.range(at: 1)
            if let range = Range(range, in: text) {
                let coordinates = text[range]
                print(coordinates)
                let arr = coordinates.components(separatedBy: ",")
                if arr.count >= 3,
                   let x = Int(arr[0].trimmingCharacters(in: .whitespaces)),
                   let y = Int(arr[1].trimmingCharacters(in: .whitespaces)),
                   let z = Int(arr[2].trimmingCharacters(in: .whitespaces))
                {
                    return Coordinates(x: x, y: y, z: z)
                }
                return nil
            }
        }
        return nil
    }
}
