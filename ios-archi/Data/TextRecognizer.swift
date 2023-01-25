//
//  TextRecognizer.swift
//  ios-archi
//
//  Created by takayuki.yokoda on 2023/01/26.
//

import Vision

final class TextRecognizer: ObservableObject {
    @Published private(set) var x: Int
    @Published private(set) var z: Int

    init() {
        x = 100
        z = 200
    }

    private lazy var recognizeTextRequest: VNRecognizeTextRequest = {
        let recognizeTextRequest = VNRecognizeTextRequest(completionHandler: self.handleRecognizeText)
        recognizeTextRequest.recognitionLevel = .accurate
        return recognizeTextRequest
    }()

    func performVisionRequest(image: CGImage, orientation: CGImagePropertyOrientation) {
        let requests = createVisionRequests()
        let imageRequestHandler = VNImageRequestHandler(cgImage: image,
                                                        orientation: orientation,
                                                        options: [:])

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try imageRequestHandler.perform(requests)
            } catch let error as NSError {
                print("Failed to perform image request: \(error)")
                return
            }
        }
    }
}

private extension TextRecognizer {
    func createVisionRequests() -> [VNRequest] {
        var requests: [VNRequest] = []
        requests.append(self.recognizeTextRequest)
        return requests
    }

    func handleRecognizeText(request: VNRequest?, error: Error?) {
        if let nsError = error as NSError? {
            print("Text Detection Error \(nsError)")
            return
        }

        DispatchQueue.main.async {
            guard let observations = request?.results as? [VNRecognizedTextObservation] else { return }
            print(observations)
            let maximumCandidates = 1
            var recognizedText = ""
            for observation in observations {
                guard let candidate = observation.topCandidates(maximumCandidates).first else { continue }
                recognizedText += candidate.string
            }
            print(recognizedText)
        }
    }
}
