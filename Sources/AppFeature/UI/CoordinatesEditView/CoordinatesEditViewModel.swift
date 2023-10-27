//
//  Created by yoko-yan on 2023/10/15
//

import Combine
import UIKit

// MARK: - Action

enum CoordinatesEditViewAction: Equatable {
    case setCoordinatesImage(UIImage?)
    case clearCoordinates
    case setCoordinatesX(String)
    case setCoordinatesY(String)
    case setCoordinatesZ(String)
    case getCoordinates(from: UIImage)
}

// MARK: - View model

@MainActor
final class CoordinatesEditViewModel: ObservableObject {
    @Published private(set) var uiState: CoordinatesEditUiState

    init(coordinates: Coordinates?) {
        var coordinatesX: String
        var coordinatesY: String
        var coordinatesZ: String
        if let coordinates {
            coordinatesX = "\(coordinates.x)"
            coordinatesY = "\(coordinates.y)"
            coordinatesZ = "\(coordinates.z)"
        } else {
            coordinatesX = ""
            coordinatesY = ""
            coordinatesZ = ""
        }
        uiState = CoordinatesEditUiState(
            coordinatesX: coordinatesX,
            coordinatesY: coordinatesY,
            coordinatesZ: coordinatesZ
        )
    }

    func send(action: CoordinatesEditViewAction) async {
        switch action {
        case let .setCoordinatesImage(image):
            uiState.coordinatesImage = image

        case .clearCoordinates:
            uiState.coordinatesX = ""
            uiState.coordinatesY = ""
            uiState.coordinatesZ = ""

        case let .setCoordinatesX(x):
            uiState.coordinatesX = x

        case let .setCoordinatesY(y):
            uiState.coordinatesY = y

        case let .setCoordinatesZ(z):
            uiState.coordinatesZ = z

        case let .getCoordinates(image):
            Task {
                let coordinates = try await GetCoordinatesUseCase().execute(image: image)
                if let coordinates {
                    uiState.coordinatesX = "\(coordinates.x)"
                    uiState.coordinatesY = "\(coordinates.y)"
                    uiState.coordinatesZ = "\(coordinates.z)"
                }
            }
        }
    }
}
