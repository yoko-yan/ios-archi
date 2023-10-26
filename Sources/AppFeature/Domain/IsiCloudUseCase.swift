//
//  Created by apla on 2023/10/27
//

import Foundation

protocol IsiCloudUseCase {
    func execute() -> Bool
}

struct IsiCloudUseCaseImpl: IsiCloudUseCase {
    func execute() -> Bool {
        FileManager.default.ubiquityIdentityToken != nil
    }
}
