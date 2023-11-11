//
//  Created by yoko-yan on 2023/10/27
//

import Core
import Foundation

protocol IsCloudKitContainerAvailableUseCase: AutoInjectable, AutoMockable {
    func execute() -> Bool
}

struct IsCloudKitContainerAvailableUseCaseImpl: IsCloudKitContainerAvailableUseCase {
    func execute() -> Bool {
        FileManager.default.ubiquityIdentityToken != nil
    }
}
