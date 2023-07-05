//
//  CoordinatesRepository.swift
//  ios-archi
//
//  Created by takayuki.yokoda on 2023/01/28.
//

import Combine
import Foundation
import UIKit

struct CoordinatesRepository {
    enum TestError: Error {
        case minusError
        case nilError
        case timeoutError
        case otherError
    }

    func get(image: UIImage) -> AnyPublisher<Coordinates?, RecognizeTextError> {
        let request = RecognizeTextRequest()
        let cgOrientation = CGImagePropertyOrientation(image.imageOrientation)
        guard let cgImage = image.cgImage else {
            fatalError()
        }

        return request.perform(image: cgImage, orientation: cgOrientation)
            .filter { !$0.isEmpty }
            .map { (texts: [String]) -> Coordinates? in
                makeCoordinates(texts)
            }
            .eraseToAnyPublisher()
    }

    // 座標が分割して認識されてしまったケースを考慮し、読み取れた文字を１つの文字列にして、座標の形式にマッチするものをCoordinatesにする
    private func makeCoordinates(_ texts: [String]) -> Coordinates? {
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
