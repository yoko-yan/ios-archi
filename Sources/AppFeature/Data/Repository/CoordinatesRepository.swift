//
//  CoordinatesRepository.swift
//  ios-archi
//
//  Created by takayuki.yokoda on 2023/01/28.
//

import Combine
import Foundation
import UIKit

final class CoordinatesRepository {
    enum TestError: Error {
        case minusError
        case nilError
        case timeoutError
        case otherError
    }

    func get(image: UIImage) -> AnyPublisher<String, Never> {
        let request = RecognizeTextRequest()
        let cgOrientation = CGImagePropertyOrientation(image.imageOrientation)
        guard let cgImage = image.cgImage else {
            fatalError()
        }

        return request.perform(image: cgImage, orientation: cgOrientation)
            .filter { !$0.isEmpty }
            .map { (recognizeText: String) -> String in
                let text = recognizeText
                let pattern = #"(-?[0-9]{1,4},[\s]?-?[0-9]{1,4},[\s]?-?[0-9]{1,4})"#
                // swiftlint:disable:next force_try
                let regex = try! NSRegularExpression(pattern: pattern, options: [.allowCommentsAndWhitespace])
                let matches = regex.matches(in: text, options: [], range: NSRange(0..<text.count))
                if let match = matches.first {
                    let range = match.range(at: 1)
                    if let range = Range(range, in: text) {
                        let coordinates = text[range]
                        print(coordinates)
                        return String(coordinates)
                    }
                }
                return ""
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
