//
//  Created by yoko-yan on 2023/07/03.
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
    case onRegisterButtonTap
    case onUpdateButtonTap
    case onDeleteButtonTap
    case onCloseButtonTap
    case onRegister
    case onUpdate
    case onDelete
    case onAlertDismiss
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

    func consumeEvent(_ event: ItemEditUiState.Event) {
        uiState.event.removeAll(where: { $0 == event })
    }

    func send(event: ItemEditUiState.Event) {
        uiState.event.append(event)
    }

    // FIXME:
    // swiftlint:disable:next cyclomatic_complexity
    func send(action: ItemEditViewAction) async {
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
//                    try ImageRepository().save(spotImage, fileName: spotImageName)
                    try await RemoteImageRepository().save(spotImage, fileName: spotImageName)
                }

            case .loadImage:
                if uiState.spotImage == nil, let spotImageName = uiState.input.spotImageName {
//                    uiState.spotImage = ImageRepository().load(fileName: uiState.input.spotImageName)
                    uiState.spotImage = try await RemoteImageRepository().load(fileName: spotImageName)
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
                await send(action: .onAlertDismiss)
                guard case .add = uiState.editMode else { fatalError() }
                await send(action: .saveImage)
                try await ItemsRepository().insert(item: uiState.editItem)
                send(event: .onChanged)
                send(event: .onDismiss)

            case .onUpdate:
                await send(action: .onAlertDismiss)
                guard case .update = uiState.editMode else { fatalError() }
                await send(action: .saveImage)
                try await ItemsRepository().update(item: uiState.editItem)
                send(event: .onChanged)
                send(event: .onDismiss)

            case .onDelete:
                guard case .update = uiState.editMode, let item = uiState.editMode.item else { return }
                try await ItemsRepository().delete(item: item)
                send(event: .onDeleted)
                send(event: .onDismiss)

            case .onAlertDismiss:
                uiState.confirmationAlert = nil

            case .onDismiss:
                send(event: .onDismiss)
            }
        } catch {
            print(error)
        }
    }
}
