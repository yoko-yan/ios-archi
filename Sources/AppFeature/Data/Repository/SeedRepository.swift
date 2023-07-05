//
//  SeedRepository.swift
//  ios-archi
//
//  Created by takayuki.yokoda on 2023/01/29.
//

import Combine
import Foundation
import UIKit

struct SeedRepository {
    func get(image: UIImage) -> AnyPublisher<Seed?, RecognizeTextError> {
        let request = RecognizeTextRequest()
        let cgOrientation = CGImagePropertyOrientation(image.imageOrientation)
        guard let cgImage = image.cgImage else {
            fatalError()
        }

        return request.perform(image: cgImage, orientation: cgOrientation)
            .filter { !$0.isEmpty }
            .map { (texts: [String]) -> Seed? in
                makeSeed(texts)
            }
            .eraseToAnyPublisher()
    }

    func get(image: UIImage, completionHandler: @escaping (Result<Seed?, NewRecognizeTextError>) -> Void) {
        let request = NewRecognizeTextRequest()
        let cgOrientation = CGImagePropertyOrientation(image.imageOrientation)
        guard let cgImage = image.cgImage else {
            fatalError()
        }

        request.perform(image: cgImage, orientation: cgOrientation) { result in
            switch result {
            case let .success(texts):
                completionHandler(.success(makeSeed(texts)))
            case let .failure(error):
                completionHandler(.failure(error))
            }
        }
    }

    // 読み取れた数字が複数ある場合は、より大きい数字をSeedにする
    private func makeSeed(_ texts: [String]) -> Seed? {
        let filterdTexs = texts.compactMap { Seed($0) }
        guard let max = filterdTexs.max(by: { a, b -> Bool in
            a.rawValue < b.rawValue
        }) else { return nil }
        return max
    }
}
