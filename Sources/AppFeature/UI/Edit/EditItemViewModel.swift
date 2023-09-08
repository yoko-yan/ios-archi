//
//  Created by takayuki.yokoda on 2023/07/03.
//

import Combine
import SwiftUI
import UIKit

// MARK: - Action

enum EditViewAction: Equatable {
    case clearSeed
    case clearCoordinates
    case getSeed(image: UIImage)
    case getCoordinates(image: UIImage)
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
final class EditItemViewModel: ObservableObject {
    @Published private(set) var uiState: EditItemUiState

    private var cancellables: Set<AnyCancellable> = []

    var input: Binding<EditItemUiState.Input> {
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

    var coordinatesImage: Binding<UIImage?> {
        Binding(
            get: { self.uiState.coordinatesImage },
            set: { newValue in
                self.uiState.coordinatesImage = newValue
            }
        )
    }

    init(item: Item?) {
        uiState = EditItemUiState(
            editMode: EditItemUiState.EditMode(item: item),
            input: EditItemUiState.Input(item: item)
        )
    }

    func consumeEvent() {
        uiState.event = nil
    }

    func send(_ action: EditViewAction) async {
        switch action {
        case .clearSeed:
            uiState.input.seed = nil

        case .clearCoordinates:
            uiState.input.coordinates = nil

        case let .getSeed(image):
            do {
                let seed = try await GetSeedUseCaseImpl().execute(image: image)
//                let seed = try await GetSeed2UseCaseImpl().execute(image: image)
                uiState.input.seed = seed
            } catch {
                print(error)
            }

        case let .getCoordinates(image):
            do {
                let coordinates = try await GetCoordinatesUseCaseImpl().execute(image: image)
                uiState.input.coordinates = coordinates
            } catch {
                print(error)
            }

        case .saveImage:
            if let coordinatesImage = uiState.coordinatesImage {
                let coordinatesImageName = uiState.input.coordinatesImageName ?? UUID().uuidString
                uiState.input.coordinatesImageName = coordinatesImageName
                do {
                    try ImageRepository().save(coordinatesImage, fileName: coordinatesImageName)
                } catch {
                    print(error)
                }
            }

            if let seedImage = uiState.seedImage {
                let seedImageName = uiState.input.seedImageName ?? UUID().uuidString
                uiState.input.seedImageName = seedImageName
                do {
                    try ImageRepository().save(seedImage, fileName: seedImageName)
                } catch {
                    print(error)
                }
            }

        case .loadImage:
            uiState.coordinatesImage = ImageRepository().load(fileName: uiState.input.coordinatesImageName)
            uiState.seedImage = ImageRepository().load(fileName: uiState.input.seedImageName)

        case .onRegisterButtonClick:
            await send(.onRegister)

        case .onRegister:
            do {
                guard case .add = uiState.editMode else { fatalError() }
                await send(.saveImage)
                try await ItemRepository().insert(item: uiState.editItem)
                uiState.event = .updated
                await send(.onAlertDismiss)
            } catch {
                print(error)
            }

        case .onUpdateButtonClick:
            uiState.confirmationAlert = .confirmUpdate(.onUpdate)

        case .onUpdate:
            do {
                guard case .update = uiState.editMode else { fatalError() }
                await send(.saveImage)
                try await ItemRepository().update(item: uiState.editItem)
                uiState.event = .updated
                await send(.onAlertDismiss)
            } catch {
                print(error)
            }

        case .onAlertDismiss:
            uiState.confirmationAlert = nil

        case .onDeleteButtonClick:
            uiState.confirmationAlert = .confirmDeletion(.onDelete)

        case .onDelete:
            guard case .update = uiState.editMode, let item = uiState.editMode.item else { return }
            do {
                try await ItemRepository().delete(item: item)
            } catch {
                print(error)
            }
            uiState.event = .deleted

        case .onCloseButtonTap:
            if uiState.editItem.seed == uiState.editMode.item?.seed,
               uiState.editItem.coordinates == uiState.editMode.item?.coordinates,
               uiState.editItem.coordinatesImageName == uiState.editMode.item?.coordinatesImageName,
               uiState.editItem.seedImageName == uiState.editMode.item?.seedImageName
            {
                uiState.event = .dismiss
            } else {
                uiState.confirmationAlert = .confirmDismiss(.onDismiss)
            }
        case .onDismiss:
            uiState.event = .dismiss
        }
    }
}
