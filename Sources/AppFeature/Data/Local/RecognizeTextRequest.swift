//
//  RecognizeTextRequest.swift
//  ios-archi
//
//  Created by takayuki.yokoda on 2023/01/26.
//

import Combine
import Vision

final class RecognizeTextRequest {
    private var subject: CurrentValueSubject<[String], Never> = .init([])

    func perform(image: CGImage, orientation: CGImagePropertyOrientation) -> AnyPublisher<[String], Never> {
        let request = VNRecognizeTextRequest { request, error in
            if let nsError = error as NSError? {
                print("Text Detection Error \(nsError)")
                return
            }

            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            print(observations)
            let maximumCandidates = 1
            let strings = observations.compactMap { observation in
                observation.topCandidates(maximumCandidates).first?.string
            }
            // 得られたテキストを出力する
            print(strings)
            self.subject.send(strings)
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
                return
            }
        }

        return subject.eraseToAnyPublisher()
    }
}
