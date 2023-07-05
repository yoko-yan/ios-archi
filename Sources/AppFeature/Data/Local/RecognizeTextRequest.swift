//
//  Created by takayuki.yokoda on 2023/01/26.
//

import Combine
import UIKit
import Vision

enum RecognizeTextError: Error {
    case error(Error)
    case GetCgImage
    case RecognizeText
    case RecognizeTextRequest
}

struct RecognizeTextRequest {
    func perform(image: UIImage) -> AnyPublisher<[String], RecognizeTextError> {
        Future<[String], RecognizeTextError> { promise in
            let cgOrientation = CGImagePropertyOrientation(image.imageOrientation)
            guard let cgImage = image.cgImage else {
                return promise(.failure(RecognizeTextError.GetCgImage))
            }

            let request = VNRecognizeTextRequest { request, error in
                if let error {
                    return promise(.failure(RecognizeTextError.error(error)))
                }

                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    return promise(.failure(RecognizeTextError.RecognizeText))
                }
                let maximumCandidates = 1
                let strings = observations.compactMap { observation in
                    observation.topCandidates(maximumCandidates).first?.string
                }
                // 得られたテキストを出力する
                print(strings)
                return promise(.success(strings))
            }

            request.recognitionLevel = .accurate
            request.recognitionLanguages = ["ja-JP"]

            var requests: [VNRequest] = []
            requests.append(request)

            let imageRequestHandler = VNImageRequestHandler(
                cgImage: cgImage,
                orientation: cgOrientation,
                options: [:]
            )

            DispatchQueue.global(qos: .userInteractive).async {
                do {
                    try imageRequestHandler.perform(requests)
                } catch {
                    print("Failed to perform image request: \(error)")
                    return promise(.failure(RecognizeTextError.RecognizeTextRequest))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
