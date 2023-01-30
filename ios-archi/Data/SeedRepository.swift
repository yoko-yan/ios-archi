//
//  SeedRepository.swift
//  ios-archi
//
//  Created by takayuki.yokoda on 2023/01/29.
//

import Combine
import Foundation
import UIKit

final class SeedRepository {
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
                let arr = text.components(separatedBy: " ")
                let filterdArr = arr.filter { Int($0) != nil }.map { Int($0)! }
                guard let max = filterdArr.max() else { return "" }
                return String(max)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
