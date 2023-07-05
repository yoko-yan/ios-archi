//
//  Created by takayuki.yokoda on 2023/01/26.
//

import Combine
import Vision

enum RecognizeTextError: Error {
    case error(Error)
    case NoRecognizedText
    case FailRecognizeTextRequest
}

struct RecognizeTextRequest {
    func perform(image: CGImage, orientation: CGImagePropertyOrientation) -> AnyPublisher<[String], RecognizeTextError> {
        Future<[String], RecognizeTextError> { promise in
            let request = VNRecognizeTextRequest { request, error in
                if let error {
                    return promise(.failure(RecognizeTextError.error(error)))
                }

                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    return promise(.failure(RecognizeTextError.NoRecognizedText))
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
                cgImage: image,
                orientation: orientation,
                options: [:]
            )

            DispatchQueue.global(qos: .userInteractive).async {
                do {
                    try imageRequestHandler.perform(requests)
                } catch {
                    print("Failed to perform image request: \(error)")
                    return promise(.failure(RecognizeTextError.FailRecognizeTextRequest))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
