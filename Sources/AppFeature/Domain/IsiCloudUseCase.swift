//
//  Created by yoko-yan on 2023/10/27
//

import Core
import Foundation

protocol IsiCloudUseCase: AutoInjectable, AutoMockable {
    func execute() -> Bool
}

struct IsiCloudUseCaseImpl: IsiCloudUseCase {
    func execute() -> Bool {
        FileManager.default.ubiquityIdentityToken != nil
    }
}
