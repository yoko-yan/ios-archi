//
//  Created by yoko-yan on 2023/10/27
//

import Core
import Foundation

protocol IsiCloudUseCase {
    func execute() -> Bool
}

struct IsiCloudUseCaseImpl: IsiCloudUseCase {
    func execute() -> Bool {
        FileManager.default.ubiquityIdentityToken != nil
    }
}

// MARK: - InjectedValues

private struct IsiCloudUseCaseKey: InjectionKey {
    static var currentValue: IsiCloudUseCase = IsiCloudUseCaseImpl()
}

extension InjectedValues {
    var isiCloudUseCase: IsiCloudUseCase {
        get { Self[IsiCloudUseCaseKey.self] }
        set { Self[IsiCloudUseCaseKey.self] = newValue }
    }
}
