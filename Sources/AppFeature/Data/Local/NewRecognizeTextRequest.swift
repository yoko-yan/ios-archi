//
//  Created by yokoda.takayuki on 2023/07/05.
//

import Foundation
import Vision

enum NewRecognizeTextError: Error {
    case error(Error)
    case NoRecognizedText
    case FailRecognizeTextRequest
}

struct NewRecognizeTextRequest {
    func perform(image: CGImage, orientation: CGImagePropertyOrientation, completionHandler: @escaping @Sendable (Result<[String], NewRecognizeTextError>) -> Void) {
        let request = VNRecognizeTextRequest { request, error in
            if let error {
                completionHandler(.failure(NewRecognizeTextError.error(error)))
                return
            }

            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            let maximumCandidates = 1
            let strings = observations.compactMap { observation in
                observation.topCandidates(maximumCandidates).first?.string
            }
            // 得られたテキストを出力する
            print(strings)
            completionHandler(.success(strings))
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
                completionHandler(.failure(NewRecognizeTextError.FailRecognizeTextRequest))
                return
            }
        }
    }
}
