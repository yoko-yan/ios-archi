//
//  Created by apla on 2023/10/08
//

import Combine
import SwiftUI
import UIKit

// MARK: - Action

enum WorldEditViewAction: Equatable {
    case clearSeed
    case getSeed(image: UIImage)
    case setSeed(seed: Seed)
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
final class WorldEditItemViewModel: ObservableObject {
    @Published private(set) var uiState: WorldEditItemUiState

    var input: Binding<WorldEditItemUiState.Input> {
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
            editMode: WorldEditItemUiState.EditMode(world: world),
            input: WorldEditItemUiState.Input(world: world)
        )
    }

    func consumeEvent() {
        uiState.event = nil
    }

    // FIXME:
    // swiftlint:disable:next cyclomatic_complexity
    func send(_ action: WorldEditViewAction) async {
        do {
            switch action {
            case .clearSeed:
                uiState.input.seed = nil

            case let .getSeed(image):
                let seed = try await GetSeedUseCaseImpl().execute(image: image)
//                let seed = try await GetSeed2UseCaseImpl().execute(image: image)
                uiState.input.seed = seed

            case let .setSeed(seed: seed):
                uiState.input.seed = seed

            case .onRegisterButtonClick:
                await send(.onRegister)

            case .onRegister:
                guard case .add = uiState.editMode else { fatalError() }
                try await WorldsRepository().insert(world: uiState.editItem)
                uiState.event = .updated
                await send(.onAlertDismiss)

            case .onUpdateButtonClick:
                uiState.confirmationAlert = .confirmUpdate(.onUpdate)

            case .onUpdate:
                guard case .update = uiState.editMode else { fatalError() }
                try await WorldsRepository().update(world: uiState.editItem)
                uiState.event = .updated
                await send(.onAlertDismiss)

            case .onAlertDismiss:
                uiState.confirmationAlert = nil

            case .onDeleteButtonClick:
                uiState.confirmationAlert = .confirmDeletion(.onDelete)

            case .onDelete:
                guard case .update = uiState.editMode, let world = uiState.editMode.world else { return }

                try await WorldsRepository().delete(world: world)
                uiState.event = .deleted

            case .onCloseButtonTap:
                if uiState.editItem.seed == uiState.editMode.world?.seed {
                    uiState.event = .dismiss
                } else {
                    uiState.confirmationAlert = .confirmDismiss(.onDismiss)
                }

            case .onDismiss:
                uiState.event = .dismiss
            }
        } catch {
            print(error)
        }
    }
}
