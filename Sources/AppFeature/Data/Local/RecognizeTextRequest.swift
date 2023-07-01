//
//  RecognizeTextRequest.swift
//  ios-archi
//
//  Created by takayuki.yokoda on 2023/01/26.
//

import Combine
import Vision

final class RecognizeTextRequest {
    private var subject: CurrentValueSubject<String, Never> = .init("")

    func perform(image: CGImage, orientation: CGImagePropertyOrientation) -> AnyPublisher<String, Never> {
        let request = VNRecognizeTextRequest(completionHandler: handle)
        request.recognitionLevel = .accurate
        //　日本語を指定する
        request.recognitionLanguages = ["ja-JP"]

        var requests: [VNRequest] = []
        requests.append(request)

        let imageRequestHandler = VNImageRequestHandler(
            cgImage: image,
            orientation: orientation,
            options: [:]
        )

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try imageRequestHandler.perform(requests)
            } catch let error as NSError {
                print("Failed to perform image request: \(error)")
                return
            }
        }

        return subject.eraseToAnyPublisher()
    }
}

private extension RecognizeTextRequest {
    func handle(request: VNRequest?, error: Error?) {
        if let nsError = error as NSError? {
            print("Text Detection Error \(nsError)")
            return
        }

        guard let observations = request?.results as? [VNRecognizedTextObservation] else { return }
        print(observations)
        let maximumCandidates = 1
        var text = ""
        for observation in observations {
            guard let candidate = observation.topCandidates(maximumCandidates).first else { continue }
            text += "\(candidate.string) "
        }
        print(text)
        subject.send(String(text))
    }
}
