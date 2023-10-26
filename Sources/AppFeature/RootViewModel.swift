//
//  Created by yoko-yan on 2023/10/25
//

import Combine
import Core
import CoreData
import Foundation

// MARK: - View model

@MainActor
final class RootViewModel: ObservableObject {
    @Published private(set) var uiState = RootUiState()

    private let isiCloudUseCase: IsiCloudUseCase

    init(
        isiCloudUseCase: IsiCloudUseCase = IsiCloudUseCaseImpl()
    ) {
        self.isiCloudUseCase = isiCloudUseCase
    }

    // FIXME:
    func load() async {
        if !isiCloudUseCase.execute() {
            uiState.isLaunching = false
            return
        }

        do {
            uiState.isLaunching = try await IsiCloudSyncingUseCaseImpl().execute()
        } catch {
            print(error)
        }
    }
}
