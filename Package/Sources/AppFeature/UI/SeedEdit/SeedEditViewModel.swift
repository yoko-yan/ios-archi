import UIKit

// MARK: - Action

enum SeedEditViewAction: Equatable {
    case setSeedImage(UIImage?)
    case clearSeed
    case setSeed(String)
    case getSeed(from: UIImage)
    case onChangeButtonTap
}

// MARK: - View model

@MainActor
@Observable
final class SeedEditViewModel {
    private(set) var uiState: SeedEditUiState

    init(seed: Seed?) {
        uiState = SeedEditUiState(
            seedText: seed?.text ?? ""
        )
    }

    func consumeEvent(_ event: SeedEditUiState.Event) {
        uiState.events.removeAll(where: { $0 == event })
    }

    private func send(event: SeedEditUiState.Event) {
        uiState.events.append(event)
    }

    func send(action: SeedEditViewAction) async {
        switch action {
        case let .setSeedImage(image):
            uiState.seedImage = image
        case .clearSeed:
            uiState.seedText = ""
        case let .setSeed(text):
            if !text.isEmpty, let validate = SeedValidator.validate(seed: text).validationError {
                uiState.validationErrors = [validate]
            } else {
                uiState.validationErrors = []
            }
//            // 数字以外が入力された場合に自動的に修正する場合
//            if let txt = convertibleInt(text: text) {
//                uiState.seedText = txt
//            }
            uiState.seedText = text
        case let .getSeed(image):
            do {
                let seed = try await GetSeedFromImageUseCaseImpl().execute(image: image)
                if let seed {
                    uiState.seedText = seed.text
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

private extension SeedEditViewModel {
    func convertibleInt(text: String) -> String? {
        let str = text.withOutWhitespaces()
        if let int = Int(str) {
            return String(int)
        }
        return nil
    }

    func validate() {
        var validationErrors: [SeedValidationError] = []
        if !uiState.seedText.isEmpty, let validate = SeedValidator.validate(seed: uiState.seedText).validationError {
            validationErrors.append(validate)
        }
        uiState.validationErrors = validationErrors
    }
}
