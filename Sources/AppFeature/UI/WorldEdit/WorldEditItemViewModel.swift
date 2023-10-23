//
//  Created by yoko-yan on 2023/10/08
//

import Combine
import SwiftUI
import UIKit

// MARK: - Action

enum WorldEditViewAction: Equatable {
    case clearSeed
    case getSeed(image: UIImage)
    case setSeed(seed: Seed)
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

    func consumeEvent(_ event: WorldEditItemUiState.Event) {
        uiState.event.removeAll(where: { $0 == event })
    }

    func send(event: WorldEditItemUiState.Event) {
        uiState.event.append(event)
    }

    // FIXME:
    // swiftlint:disable:next cyclomatic_complexity
    func send(action: WorldEditViewAction) async {
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
                guard case .add = uiState.editMode else { fatalError() }
                try await WorldsRepository().insert(world: uiState.editItem)
                send(event: .onChanged)
                await send(action: .onAlertDismiss)

            case .onUpdateButtonTap:
                uiState.confirmationAlert = .confirmUpdate(.onUpdate)

            case .onUpdate:
                guard case .update = uiState.editMode else { fatalError() }
                try await WorldsRepository().update(world: uiState.editItem)
                send(event: .onChanged)
                await send(action: .onAlertDismiss)

            case .onDelete:
                guard case .update = uiState.editMode, let world = uiState.editMode.world else { return }

                try await WorldsRepository().delete(world: world)
                send(event: .onDeleted)

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
