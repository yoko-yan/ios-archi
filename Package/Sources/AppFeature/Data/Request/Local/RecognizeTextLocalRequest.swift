import UIKit
@preconcurrency import Vision

enum RecognizeTextLocalRequestError: Error {
    case error(Error)
    case getCgImage
    case recognizeText
    case recognizeTextRequest
}

struct RecognizeTextLocalRequest {
    private func perform(image: UIImage, completionHandler: @escaping @Sendable (Result<[String], RecognizeTextLocalRequestError>) -> Void) {
        let cgOrientation = CGImagePropertyOrientation(image.imageOrientation)
        guard let cgImage = image.cgImage else {
            completionHandler(.failure(.getCgImage))
            return
        }

        let request = VNRecognizeTextRequest { request, error in
            if let error {
                completionHandler(.failure(.error(error)))
                return
            }

            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completionHandler(.failure(.recognizeText))
                return
            }
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
            cgImage: cgImage,
            orientation: cgOrientation,
            options: [:]
        )

        Task { [requests] in
            do {
                try imageRequestHandler.perform(requests)
            } catch {
                print("Failed to perform image request: \(error)")
                completionHandler(.failure(.recognizeTextRequest))
                return
            }
        }
    }

    func perform(image: UIImage) async throws -> [String] {
        try await withCheckedThrowingContinuation { continuation in
            perform(image: image) { result in
                switch result {
                case let .success(texts):
                    continuation.resume(returning: texts)
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

//    func perform(image: UIImage) -> AnyPublisher<[String], RecognizeTextLocalRequestError> {
//        Future<[String], RecognizeTextLocalRequestError> { promise in
//            let cgOrientation = CGImagePropertyOrientation(image.imageOrientation)
//            guard let cgImage = image.cgImage else {
//                promise(.failure(.getCgImage))
//                return
//            }
//
//            let request = VNRecognizeTextRequest { request, error in
//                if let error {
//                    promise(.failure(.error(error)))
//                    return
//                }
//
//                guard let observations = request.results as? [VNRecognizedTextObservation] else {
//                    promise(.failure(.recognizeText))
//                    return
//                }
//                let maximumCandidates = 1
//                let strings = observations.compactMap { observation in
//                    observation.topCandidates(maximumCandidates).first?.string
//                }
//                // 得られたテキストを出力する
//                print(strings)
//                return promise(.success(strings))
//            }
//
//            request.recognitionLevel = .accurate
//            request.recognitionLanguages = ["ja-JP"]
//
//            var requests: [VNRequest] = []
//            requests.append(request)
//
//            let imageRequestHandler = VNImageRequestHandler(
//                cgImage: cgImage,
//                orientation: cgOrientation,
//                options: [:]
//            )
//
//            Task { [requests] in
//                do {
//                    try imageRequestHandler.perform(requests)
//                } catch {
//                    print("Failed to perform image request: \(error)")
//                    promise(.failure(.recognizeTextRequest))
//                    return
//                }
//            }
//        }
//        .eraseToAnyPublisher()
//    }
}
