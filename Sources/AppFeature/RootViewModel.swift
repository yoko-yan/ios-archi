//
//  Created by yoko-yan on 2023/10/25
//

import Core
import CoreData
import Foundation

// MARK: - View model

@MainActor
final class RootViewModel: ObservableObject {
    @Injected(\.synchronizeWithCloudUseCase) var synchronizeWithCloudUseCase
    @Injected(\.isiCloudUseCase) var isiCloudUseCase

    @Published private(set) var uiState = RootUiState()

    init() {}

    // FIXME:
    func load() async {
        if !isiCloudUseCase.execute() {
            uiState.isLaunching = false
            return
        }

        do {
            uiState.isLaunching = try await synchronizeWithCloudUseCase.execute()
        } catch {
            print(error)
        }
    }
}
