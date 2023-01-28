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
    func get(imageData: Data) -> AnyPublisher<String, Never> {
        let request = RecognizeTextRequest()
        let image = UIImage(data: imageData)!
        let cgOrientation = CGImagePropertyOrientation(image.imageOrientation)
        guard let cgImage = image.cgImage else {
            fatalError()
        }

        return request.perform(image: cgImage, orientation: cgOrientation)
            .filter { !$0.isEmpty }
            .map { (recognizeText: String) -> String in
                let pattern = "(-?[0-9]{1,4}, -?[0-9]{1,4}, -?[0-9]{1,4})"
                let regex = try! NSRegularExpression(pattern: pattern, options: [])
                let matches = regex.matches(in: recognizeText, options: [], range: NSRange(0..<recognizeText.count))
                if let match = matches.first {
                    let range = match.range(at:1)
                    if let range = Range(range, in: recognizeText) {
                        let position = recognizeText[range]
                        print(position)
                        return String(position)
                    }
                }
                return ""
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

