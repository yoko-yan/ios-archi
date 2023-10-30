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
    case onChangeButtonTap
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

    func consumeEvent(_ event: CoordinatesEditUiState.Event) {
        uiState.events.removeAll(where: { $0 == event })
    }

    private func send(event: CoordinatesEditUiState.Event) {
        uiState.events.append(event)
    }

    // swiftlint:disable:next cyclomatic_complexity
    func send(action: CoordinatesEditViewAction) async {
        switch action {
        case let .setCoordinatesImage(image):
            uiState.coordinatesImage = image

        case .clearCoordinates:
            uiState.coordinatesX = ""
            uiState.coordinatesY = ""
            uiState.coordinatesZ = ""

        case let .setCoordinatesX(text):
            if !text.isEmpty, let validate = CoordinatesValidator.validate(x: text).validationError {
                uiState.validationErrors = [validate]
            } else {
                uiState.validationErrors = []
            }
//            // 数字以外が入力された場合に自動的に修正する場合
//            if let txt = convertibleInt(text: text) {
//                uiState.coordinatesX = txt
//            }
            uiState.coordinatesX = text

        case let .setCoordinatesY(text):
            if !text.isEmpty, let validate = CoordinatesValidator.validate(y: text).validationError {
                uiState.validationErrors = [validate]
            } else {
                uiState.validationErrors = []
            }
//            // 数字以外が入力された場合に自動的に修正する場合
//            if let txt = convertibleInt(text: text) {
//                uiState.coordinatesY = txt
//            }
            uiState.coordinatesY = text

        case let .setCoordinatesZ(text):
            if !text.isEmpty, let validate = CoordinatesValidator.validate(z: text).validationError {
                uiState.validationErrors = [validate]
            } else {
                uiState.validationErrors = []
            }
//            // 数字以外が入力された場合に自動的に修正する場合
//            if let txt = convertibleInt(text: text) {
//                uiState.coordinatesZ = txt
//            }
            uiState.coordinatesZ = text

        case let .getCoordinates(image):
            do {
                let coordinates = try await GetCoordinatesFromImageUseCase().execute(image: image)
                if let coordinates {
                    uiState.coordinatesX = "\(coordinates.x)"
                    uiState.coordinatesY = "\(coordinates.y)"
                    uiState.coordinatesZ = "\(coordinates.z)"
                }
            } catch {
                print(error)
            }

        case .onChangeButtonTap:
            if validate() {
                send(event: .onChanged)
            }
        }
    }
}

// MARK: - Privates

private extension CoordinatesEditViewModel {
    func convertibleInt(text: String) -> String? {
        let str = text.withOutWhitespaces()
        if let int = Int(str) {
            return String(int)
        }
        return nil
    }

    func validate() -> Bool {
        var validationErrors: [CoordinatesValidationError] = []
        if let validateX = CoordinatesValidator.validate(x: uiState.coordinatesX).validationError {
            validationErrors.append(validateX)
        }
        if let validateY = CoordinatesValidator.validate(y: uiState.coordinatesY).validationError {
            validationErrors.append(validateY)
        }
        if let validateZ = CoordinatesValidator.validate(z: uiState.coordinatesZ).validationError {
            validationErrors.append(validateZ)
        }
        uiState.validationErrors = validationErrors
        return uiState.validationErrors.isEmpty
    }
}
