//
//  Created by yoko-yan on 2023/10/15
//

import Combine
import UIKit

// MARK: - Action

enum CoordinatesEditViewAction: Equatable {
    case setCoordinatesImage(UIImage?)
    case clearCoordinates
    case setCoordinates(String?)
    case getCoordinates(from: UIImage)
}

// MARK: - View model

@MainActor
final class CoordinatesEditViewModel: ObservableObject {
    @Published private(set) var uiState: CoordinatesEditUiState

    init(coordinates: String?) {
        uiState = CoordinatesEditUiState(
            coordinates: coordinates
        )
    }

    func send(action: CoordinatesEditViewAction) async {
        do {
            switch action {
            case let .setCoordinatesImage(image):
                uiState.coordinatesImage = image

            case .clearCoordinates:
                uiState.coordinates = nil

            case let .setCoordinates(coordinates):
                uiState.coordinates = coordinates

            case let .getCoordinates(image):
                let coordinates = try await GetCoordinatesUseCase().execute(image: image)
                if let coordinates = coordinates?.text {
                    uiState.coordinates = coordinates
                }
            }
        } catch {
            print(error)
        }
    }
}
