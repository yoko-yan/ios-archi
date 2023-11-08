//
//  Created by yoko-yan on 2023/10/25
//

import Core
import CoreData
import Foundation

// MARK: - View model

@MainActor
final class RootViewModel: ObservableObject {
    @Injected(\.synchronizeWithCloudUseCase) var synchronizeWithCloud
    @Injected(\.isCloudKitContainerAvailableUseCase) var isCloudKitContainerAvailableUseCase

    @Published private(set) var uiState = RootUiState()

    // FIXME:
    func load() async {
        if !isCloudKitContainerAvailableUseCase.execute() {
            uiState.isLaunching = false
            return
        }

        do {
            uiState.isLaunching = try await synchronizeWithCloud.execute()
        } catch {
            print(error)
            uiState.isLaunching = false
        }
    }
}
