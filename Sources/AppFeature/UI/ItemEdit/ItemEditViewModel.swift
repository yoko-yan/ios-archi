//
//  Created by takayuki.yokoda on 2023/07/03.
//

import Combine
import UIKit

// MARK: - Action

enum ItemEditViewAction: Equatable {
    case setSpotImage(UIImage?)
    case clearCoordinates
    case setCoordinates(String?)
    case getCoordinates(from: UIImage)
    case getWorlds
    case setWorld(World)
    case saveImage
    case loadImage
    case onRegisterButtonClick
    case onRegister
    case onUpdateButtonClick
    case onUpdate
    case onDeleteButtonClick
    case onDelete
    case onAlertDismiss
    case onCloseButtonTap
    case onDismiss
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

    func consumeEvent() {
        uiState.event = nil
    }

    // FIXME:
    // swiftlint:disable:next cyclomatic_complexity
    func send(_ action: ItemEditViewAction) async {
        do {
            switch action {
            case let .setSpotImage(image):
                uiState.spotImage = image

            case .clearCoordinates:
                uiState.input.coordinates = nil

            case let .setCoordinates(coordinates):
                uiState.input.coordinates = coordinates

            case let .getCoordinates(image):
                let coordinates = try await GetCoordinatesUseCase().execute(image: image)
                if let coordinates = coordinates?.text {
                    uiState.input.coordinates = coordinates
                }

            case .getWorlds:
                uiState.worlds = try await WorldsRepository().load()

            case let .setWorld(world):
                uiState.input.world = world

            case .saveImage:
                if let spotImage = uiState.spotImage {
                    let spotImageName = uiState.input.spotImageName ?? UUID().uuidString
                    uiState.input.spotImageName = spotImageName
                    try ImageRepository().save(spotImage, fileName: spotImageName)
                }

            case .loadImage:
                if uiState.spotImage == nil {
                    uiState.spotImage = ImageRepository().load(fileName: uiState.input.spotImageName)
                }

            case .onRegisterButtonClick:
                await send(.onRegister)

            case .onRegister:
                guard case .add = uiState.editMode else { fatalError() }
                await send(.saveImage)
                try await ItemsRepository().insert(item: uiState.editItem)
                uiState.event = .updated
                await send(.onAlertDismiss)

            case .onUpdateButtonClick:
                uiState.confirmationAlert = .confirmUpdate(.onUpdate)

            case .onUpdate:
                guard case .update = uiState.editMode else { fatalError() }
                await send(.saveImage)
                try await ItemsRepository().update(item: uiState.editItem)
                uiState.event = .updated
                await send(.onAlertDismiss)

            case .onAlertDismiss:
                uiState.confirmationAlert = nil

            case .onDeleteButtonClick:
                uiState.confirmationAlert = .confirmDeletion(.onDelete)

            case .onDelete:
                guard case .update = uiState.editMode, let item = uiState.editMode.item else { return }

                try await ItemsRepository().delete(item: item)
                uiState.event = .deleted

            case .onCloseButtonTap:
                if uiState.isChanged {
                    uiState.confirmationAlert = .confirmDismiss(.onDismiss)
                } else {
                    uiState.event = .dismiss
                }

            case .onDismiss:
                uiState.event = .dismiss
            }
        } catch {
            print(error)
        }
    }
}
