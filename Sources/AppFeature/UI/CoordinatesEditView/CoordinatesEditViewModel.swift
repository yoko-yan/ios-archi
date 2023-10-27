//
//  Created by yoko-yan on 2023/10/15
//

import Combine
import UIKit

// MARK: - Action

enum CoordinatesEditViewAction: Equatable {
    case setCoordinatesImage(UIImage?)
    case clearCoordinates
    case setCoordinatesX(String?)
    case setCoordinatesY(String?)
    case setCoordinatesZ(String?)
    case getCoordinates(from: UIImage)
}

// MARK: - View model

@MainActor
final class CoordinatesEditViewModel: ObservableObject {
    @Published private(set) var uiState: CoordinatesEditUiState

    init(coordinatesX: String?, coordinatesY: String?, coordinatesZ: String?) {
        uiState = CoordinatesEditUiState(
            coordinatesX: coordinatesX,
            coordinatesY: coordinatesY,
            coordinatesZ: coordinatesZ
        )
    }

    func send(action: CoordinatesEditViewAction) async {
        do {
            switch action {
            case let .setCoordinatesImage(image):
                uiState.coordinatesImage = image

            case .clearCoordinates:
                uiState.coordinatesX = nil
                uiState.coordinatesY = nil
                uiState.coordinatesZ = nil

            case let .setCoordinatesX(x):
                uiState.coordinatesX = x

            case let .setCoordinatesY(y):
                uiState.coordinatesY = y

            case let .setCoordinatesZ(z):
                uiState.coordinatesZ = z

            case let .getCoordinates(image):
                let coordinates = try await GetCoordinatesUseCase().execute(image: image)
                if let coordinates {
                    uiState.coordinatesX = "\(coordinates.x)"
                    uiState.coordinatesY = "\(coordinates.y)"
                    uiState.coordinatesZ = "\(coordinates.z)"
                }
            }
        } catch {
            print(error)
        }
    }
}
