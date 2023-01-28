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
                let arr = recognizeText.components(separatedBy: " ")
                let filterdArr = arr.filter { Int($0) != nil }.map { Int($0)! }
                guard let max = filterdArr.max() else { return "" }
                return String(max)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
