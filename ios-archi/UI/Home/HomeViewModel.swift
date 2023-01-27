//
//  HomeViewModel.swift
//  ios-archi
//
//  Created by yokoda.takayuki on 2023/01/28.
//

import UIKit

struct HomeViewModel {
    var state: HomeViewState

    init(_ state: HomeViewState = .init()) {
        self.state = state
    }

    func getCoordinate(imageData: Data) {
        let image = UIImage(data: imageData)!
        let cgOrientation = CGImagePropertyOrientation(image.imageOrientation)
        guard let cgImage = image.cgImage else {
            return
        }

        let textRecognizer = TextRecognizer()
        textRecognizer.performVisionRequest(image: cgImage, orientation: cgOrientation)
    }
}
