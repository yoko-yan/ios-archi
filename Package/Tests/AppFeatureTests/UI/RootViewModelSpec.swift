// swiftlint:disable implicitly_unwrapped_optional

import Core
import Nimble
import Quick

@testable import AppFeature

class RootViewModelSpec: AsyncSpec {
    override class func spec() {
        var isCloudKitContainerAvailableUseCaseMock: IsCloudKitContainerAvailableUseCaseMock!
        var synchronizeWithCloudUseCaseMock: SynchronizeWithCloudUseCaseMock!
        var viewModel: RootViewModel!

        describe("load") {
            beforeEach {
                isCloudKitContainerAvailableUseCaseMock = IsCloudKitContainerAvailableUseCaseMock()
                InjectedValues[\.isCloudKitContainerAvailableUseCase] = isCloudKitContainerAvailableUseCaseMock
                synchronizeWithCloudUseCaseMock = SynchronizeWithCloudUseCaseMock()
                InjectedValues[\.synchronizeWithCloudUseCase] = synchronizeWithCloudUseCaseMock
                viewModel = await RootViewModel()
            }

            context("When iCloud is available and synchronization is successful.") {
                beforeEach {
                    isCloudKitContainerAvailableUseCaseMock.executeClosure = { true }
                    synchronizeWithCloudUseCaseMock.executeClosure = { true }
                }

                it("The app launches successfully.") { @MainActor in
                    await viewModel.load()
                    expect(isCloudKitContainerAvailableUseCaseMock.executeCallsCount) == 1
                    expect(synchronizeWithCloudUseCaseMock.executeCallsCount) == 1
                    expect(viewModel.uiState.isLaunching) == true
                }
            }
        }
    }
}

// swiftlint:enable implicitly_unwrapped_optional
