//
//  PositionRepository.swift
//  ios-archi
//
//  Created by takayuki.yokoda on 2023/01/28.
//

import Combine
import Foundation
import UIKit

final class PositionRepository {
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
            .filter { !$0.rawValue.isEmpty }
            .map { (recognizeText: RecognizeText) -> String in
                let text = recognizeText.rawValue
                let pattern = "(-?[0-9]{1,4}, -?[0-9]{1,4}, -?[0-9]{1,4})"
                // swiftlint:disable force_try
                let regex = try! NSRegularExpression(pattern: pattern, options: [.allowCommentsAndWhitespace])
                let matches = regex.matches(in: text, options: [], range: NSRange(0 ..< text.count))
                if let match = matches.first {
                    let range = match.range(at: 1)
                    if let range = Range(range, in: text) {
                        let position = text[range]
                        print(position)
                        return String(position)
                    }
                }
                return "Not Found"
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
