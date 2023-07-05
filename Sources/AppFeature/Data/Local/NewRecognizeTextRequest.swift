//
//  NewRecognizeTextRequest.swift
//
//
//  Created by yokoda.takayuki on 2023/07/05.
//

import Foundation
import Vision

struct NewRecognizeTextRequest {
    func perform(image: CGImage, orientation: CGImagePropertyOrientation, completionHandler: @escaping ([String]) -> Void) {
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
            completionHandler(strings)
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
    }
}
