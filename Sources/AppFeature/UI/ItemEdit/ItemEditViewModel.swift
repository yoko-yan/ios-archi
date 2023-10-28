//
//  Created by yoko-yan on 2023/07/03.
//

import Combine
import UIKit

// MARK: - Action

enum ItemEditViewAction: Equatable {
    case setSpotImage(UIImage?)
    case clearCoordinates
    case setCoordinates(Coordinates?)
    case getCoordinates(from: UIImage)
    case getWorlds
    case setWorld(World)
    case saveImage
    case loadImage
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

enum ItemEditError: Error {
    case registerFailed
    case updateFailed
    case deleteFailed
    case error(AppError)
}

extension ItemEditError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .registerFailed: "データの登録に失敗しました"
        case .updateFailed: "データの更新に失敗しました"
        case .deleteFailed: "データの削除に失敗しました"
        case let .error(appError): appError.errorDescription
        }
    }

    var failureReason: String? {
        switch self {
        case .registerFailed: nil
        case .updateFailed: nil
        case .deleteFailed: nil
        case let .error(appError): appError.failureReason
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .registerFailed: nil
        case .updateFailed: nil
        case .deleteFailed: nil
        case let .error(appError): appError.recoverySuggestion
        }
    }
}

// MARK: - View model

@MainActor
final class ItemEditViewModel: ObservableObject {
    @Published private(set) var uiState: ItemEditUiState

    init(item: Item?) {
        uiState = ItemEditUiState(
            editMode: ItemEditUiState.EditMode(item: item),
            input: ItemEditUiState.Input(item: item)
        )
    }

    func consumeEvent(_ event: ItemEditUiState.Event) {
        uiState.event.removeAll(where: { $0 == event })
    }

    private func send(event: ItemEditUiState.Event) {
        uiState.event.append(event)
    }

    // FIXME:
    // swiftlint:disable:next cyclomatic_complexity
    func send(action: ItemEditViewAction) async {
        switch action {
        case let .setSpotImage(image):
            uiState.spotImage = image

        case .clearCoordinates:
            uiState.input.coordinates = nil

        case let .setCoordinates(coordinates):
            uiState.input.coordinates = coordinates

        case let .getCoordinates(image):
            do {
                let coordinates = try await GetCoordinatesUseCase().execute(image: image)
                if let coordinates {
                    uiState.input.coordinates = coordinates
                }
            } catch {
                print(error)
            }

        case .getWorlds:
            do {
                uiState.worlds = try await WorldsRepository().load()
            } catch {
                print(error)
            }

        case let .setWorld(world):
            uiState.input.world = world

        case .saveImage:
            do {
                if let spotImage = uiState.spotImage {
                    let spotImageName = uiState.input.spotImageName ?? UUID().uuidString
                    uiState.input.spotImageName = spotImageName
                    try await SaveSpotImageUseCaseImpl().execute(image: spotImage, fileName: spotImageName)
                }
            } catch {
                print(error)
            }

        case .loadImage:
            do {
                if uiState.spotImage == nil, let spotImageName = uiState.input.spotImageName {
                    uiState.spotImage = try await LoadSpotImageUseCaseImpl().execute(fileName: spotImageName)
                }
            } catch {
                print(error)
            }

        case .onRegisterButtonTap:
            await send(action: .onRegister)

        case .onUpdateButtonTap:
            uiState.confirmationAlert = .confirmUpdate(.onUpdate)

        case .onDeleteButtonTap:
            uiState.confirmationAlert = .confirmDeletion(.onDelete)

        case .onCloseButtonTap:
            if uiState.isChanged {
                uiState.confirmationAlert = .confirmDismiss(.onDismiss)
            } else {
                send(event: .onDismiss)
            }

        case .onRegister:
            do {
                await send(action: .onAlertDismiss)
                guard case .add = uiState.editMode else { fatalError() }
                await send(action: .saveImage)
                try await ItemsRepository().insert(item: uiState.editItem)
                send(event: .onChanged)
                send(event: .onDismiss)
            } catch {
                uiState.error = checkCommonError(error, type: .registerFailed)
            }

        case .onUpdate:
            do {
                await send(action: .onAlertDismiss)
                guard case .update = uiState.editMode else { fatalError() }
                await send(action: .saveImage)
                try await ItemsRepository().update(item: uiState.editItem)
                send(event: .onChanged)
                send(event: .onDismiss)
            } catch {
                uiState.error = checkCommonError(error, type: .updateFailed)
            }

        case .onDelete:
            do {
                guard case .update = uiState.editMode, let item = uiState.editMode.item else { return }
                try await ItemsRepository().delete(item: item)
                send(event: .onDeleted)
                send(event: .onDismiss)
            } catch {
                print(error)
                uiState.error = checkCommonError(error, type: .deleteFailed)
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

private extension ItemEditViewModel {
    // FIXME:
    func checkCommonError(_ error: Error, type: ItemEditError) -> ItemEditError {
        print(error)
        let appError = AppError(error)
        if appError.isCommonError {
            return .error(appError)
        } else {
            return type
        }
    }
}
