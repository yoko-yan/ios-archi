//
//  Created by yoko-yan on 2023/10/25
//

import Core
import CoreData
import Foundation

// MARK: - View model

@MainActor
@Observable
final class RootViewModel {
    @ObservationIgnored
    @Injected(\.synchronizeWithCloudUseCase) private var synchronizeWithCloud

    private(set) var uiState = RootUiState()

    func load() async {
        do {
            uiState.isLaunching = try await synchronizeWithCloud.execute()
        } catch {
            print(error)
            uiState.isLaunching = false
        }
    }
}
