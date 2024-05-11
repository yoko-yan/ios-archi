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
@Observable
final class CoordinatesEditViewModel {
    private(set) var uiState: CoordinatesEditUiState

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
            coordinatesXText: coordinatesX,
            coordinatesYText: coordinatesY,
            coordinatesZText: coordinatesZ
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
            uiState.coordinatesXText = ""
            uiState.coordinatesYText = ""
            uiState.coordinatesZText = ""
        case let .setCoordinatesX(text):
            if !text.isEmpty, let validate = CoordinatesValidator.validate(x: text).validationError {
                uiState.validationErrors = [validate]
            } else {
                uiState.validationErrors = []
            }
//            // 数字以外が入力された場合に自動的に修正する場合
//            if let txt = convertibleInt(text: text) {
//                uiState.coordinatesXText = txt
//            }
            uiState.coordinatesXText = text
        case let .setCoordinatesY(text):
            if !text.isEmpty, let validate = CoordinatesValidator.validate(y: text).validationError {
                uiState.validationErrors = [validate]
            } else {
                uiState.validationErrors = []
            }
//            // 数字以外が入力された場合に自動的に修正する場合
//            if let txt = convertibleInt(text: text) {
//                uiState.coordinatesYText = txt
//            }
            uiState.coordinatesYText = text
        case let .setCoordinatesZ(text):
            if !text.isEmpty, let validate = CoordinatesValidator.validate(z: text).validationError {
                uiState.validationErrors = [validate]
            } else {
                uiState.validationErrors = []
            }
//            // 数字以外が入力された場合に自動的に修正する場合
//            if let txt = convertibleInt(text: text) {
//                uiState.coordinatesZText = txt
//            }
            uiState.coordinatesZText = text
        case let .getCoordinates(image):
            do {
                let coordinates = try await GetCoordinatesFromImageUseCase().execute(image: image)
                if let coordinates {
                    uiState.coordinatesXText = "\(coordinates.x)"
                    uiState.coordinatesYText = "\(coordinates.y)"
                    uiState.coordinatesZText = "\(coordinates.z)"
                }
            } catch {
                print(error)
            }
        case .onChangeButtonTap:
            validate()
            if uiState.valid {
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

    func validate() {
        var validationErrors: [CoordinatesValidationError] = []
        if !uiState.coordinatesXText.isEmpty, let validateX = CoordinatesValidator.validate(x: uiState.coordinatesXText).validationError {
            validationErrors.append(validateX)
        }
        if !uiState.coordinatesYText.isEmpty, let validateY = CoordinatesValidator.validate(y: uiState.coordinatesYText).validationError {
            validationErrors.append(validateY)
        }
        if !uiState.coordinatesZText.isEmpty, let validateZ = CoordinatesValidator.validate(z: uiState.coordinatesZText).validationError {
            validationErrors.append(validateZ)
        }
        uiState.validationErrors = validationErrors
    }
}
