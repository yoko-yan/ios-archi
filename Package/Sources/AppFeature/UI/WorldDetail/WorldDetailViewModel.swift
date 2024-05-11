//
//  Created by yoko-yan on 2023/10/11
//

import Combine
import SwiftUI
import UIKit

// MARK: - View model

@MainActor
@Observable
final class WorldDetailViewModel {
    private(set) var uiState: WorldDetailUiState

    init(world: World) {
        uiState = WorldDetailUiState(world: world)
    }

    func reload(world: World) {
        uiState.world = world
    }
}
