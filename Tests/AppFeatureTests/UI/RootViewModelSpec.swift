//
//  Created by yoko-yan on 2023/10/31
//

import Core
import Foundation
import Nimble
import Quick

@testable import AppFeature

class RootViewModelSpec: AsyncSpec {
    override class func spec() {
        var isiCloudUseCaseMock: IsiCloudUseCaseMock!
        var synchronizeWithCloudUseCaseMock: SynchronizeWithCloudUseCaseMock!
        var viewModel: RootViewModel!

        describe("load") {
            beforeEach {
                isiCloudUseCaseMock = IsiCloudUseCaseMock()
                InjectedValues[\.isiCloudUseCase] = isiCloudUseCaseMock
                synchronizeWithCloudUseCaseMock = SynchronizeWithCloudUseCaseMock()
                InjectedValues[\.synchronizeWithCloudUseCase] = synchronizeWithCloudUseCaseMock
                viewModel = await RootViewModel()
            }

            context("When iCloud is available and synchronization is successful.") {
                beforeEach {
                    isiCloudUseCaseMock.executeClosure = { true }
                    synchronizeWithCloudUseCaseMock.executeClosure = { true }
                }

                it("The app launches successfully.") { @MainActor in
                    await viewModel.load()
                    expect(isiCloudUseCaseMock.executeCallsCount) == 1
                    expect(synchronizeWithCloudUseCaseMock.executeCallsCount) == 1
                    expect(viewModel.uiState.isLaunching) == true
                }
            }
        }
    }
}
