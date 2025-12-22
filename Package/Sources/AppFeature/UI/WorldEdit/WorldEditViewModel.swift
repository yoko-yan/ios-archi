import Dependencies
import SwiftUI

// MARK: - Action

enum WorldEditViewAction: Equatable {
    case clearSeed
    case setName(String)
    case getSeed(image: UIImage)
    case setSeed(Seed?)
    case onRegisterButtonTap
    case onUpdateButtonTap
    case onDeleteButtonTap
    case onCloseButtonTap
    case onRegister
    case onUpdate
    case onDelete
    case onAlertDismiss
    case onErrorAlertDismiss
    case onDismiss
}

// MARK: - Error

enum WorldEditError {
    case getSeedFailed
    case registerFailed
    case updateFailed
    case deleteFailed
    case error(any Error)
    case appError(AppError)
}

extension WorldEditError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .getSeedFailed: "シード値の取得に失敗しました"
        case .registerFailed: "データの登録に失敗しました"
        case .updateFailed: "データの更新に失敗しました"
        case .deleteFailed: "データの削除に失敗しました"
        case let .error(error): error.localizedDescription
        case let .appError(appError): appError.localizedDescription
        }
    }

    var failureReason: String? {
        switch self {
        case .getSeedFailed: nil
        case .registerFailed: nil
        case .updateFailed: nil
        case .deleteFailed: nil
        case .error: nil
        case let .appError(appError): appError.failureReason
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .getSeedFailed: nil
        case .registerFailed: nil
        case .updateFailed: nil
        case .deleteFailed: nil
        case .error: nil
        case let .appError(appError): appError.recoverySuggestion
        }
    }
}

// MARK: - View model

@MainActor
@Observable
final class WorldEditViewModel {
    @ObservationIgnored
    @Dependency(\.worldsRepository) private var worldsRepository
    @ObservationIgnored
    @Published private(set) var uiState: WorldEditUiState

    var input: Binding<WorldEditUiState.Input> {
        Binding(
            get: { self.uiState.input },
            set: { newValue in
                self.uiState.input = newValue
            }
        )
    }

    var seedImage: Binding<UIImage?> {
        Binding(
            get: { self.uiState.seedImage },
            set: { newValue in
                self.uiState.seedImage = newValue
            }
        )
    }

    init(world: World?) {
        uiState = .init(
            editMode: WorldEditUiState.EditMode(world: world),
            input: WorldEditUiState.Input(world: world)
        )
    }

    func consumeEvent(_ event: WorldEditUiState.Event) {
        uiState.events.removeAll(where: { $0 == event })
    }

    func send(event: WorldEditUiState.Event) {
        uiState.events.append(event)
    }

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func send(action: WorldEditViewAction) async {
        switch action {
        case .clearSeed:
            uiState.input.seed = nil
        case let .setName(text):
            uiState.input.name = text
        case let .getSeed(image):
            do {
                let seed = try await GetSeedFromImageUseCaseImpl().execute(image: image)
//                let seed = try await GetSeed2UseCaseImpl().execute(image: image)
                uiState.input.seed = seed
            } catch {
                print(error)
                uiState.error = .error(error)
            }
        case let .setSeed(seed):
            uiState.input.seed = seed
        case .onRegisterButtonTap:
            await send(action: .onRegister)
        case .onDeleteButtonTap:
            uiState.confirmationAlert = .confirmDeletion(.onDelete)
        case .onCloseButtonTap:
            if uiState.editItem.seed == uiState.editMode.world?.seed {
                send(event: .onDismiss)
            } else {
                uiState.confirmationAlert = .confirmDismiss(.onDismiss)
            }
        case .onRegister:
            do {
                validate()
                guard uiState.valid else { return }
                guard case .new = uiState.editMode else { fatalError() }
                try await worldsRepository.insert(world: uiState.editItem)
                send(event: .onChanged)
                await send(action: .onAlertDismiss)
            } catch {
                print(error)
                uiState.error = .error(error)
            }
        case .onUpdateButtonTap:
            uiState.confirmationAlert = .confirmUpdate(.onUpdate)
        case .onUpdate:
            do {
                validate()
                guard uiState.valid else { return }
                guard case .edit = uiState.editMode else { fatalError() }
                try await worldsRepository.update(world: uiState.editItem)
                send(event: .onChanged)
                await send(action: .onAlertDismiss)
            } catch {
                print(error)
                uiState.error = .error(error)
            }
        case .onDelete:
            do {
                guard case .edit = uiState.editMode, let world = uiState.editMode.world else { return }

                try await worldsRepository.delete(world: world)
                send(event: .onDeleted)
            } catch {
                print(error)
                uiState.error = .error(error)
            }
        case .onAlertDismiss:
            uiState.confirmationAlert = nil
        case .onErrorAlertDismiss:
            uiState.error = nil
        case .onDismiss:
            send(event: .onDismiss)
        }
    }
}

// MARK: - Privates

private extension WorldEditViewModel {
    func checkCommonError(_ error: any Error, type: WorldEditError) -> WorldEditError {
        print(error)
        let appError = AppError(error)
        if appError.isCommonError {
            return .error(appError)
        } else {
            return type
        }
    }

    func convertibleInt(text: String) -> String? {
        let str = text.withOutWhitespaces()
        if let int = Int(str) {
            return String(int)
        }
        return nil
    }

    func validate() {
        var validationErrors: [SeedValidationError] = []
        if let seed = uiState.editMode.world?.seed, let validateX = SeedValidator.validate(seed: seed.text).validationError {
            validationErrors.append(validateX)
        }
        uiState.validationErrors = validationErrors
    }
}
