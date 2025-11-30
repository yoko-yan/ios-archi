// swiftlint:disable implicitly_unwrapped_optional

import Dependencies
import Nimble
import Quick

@testable import AppFeature

class RootViewModelSpec: AsyncSpec {
    override class func spec() {
        var synchronizeWithCloudUseCaseMock: SynchronizeWithCloudUseCaseMock!
        var viewModel: RootViewModel!

        describe("load") {
            beforeEach {
                synchronizeWithCloudUseCaseMock = SynchronizeWithCloudUseCaseMock()
            }

            context("When iCloud is available and synchronization is successful.") {
                beforeEach {
                    synchronizeWithCloudUseCaseMock.executeClosure = {}
                }

                it("The app launches successfully.") { @MainActor in
                    await withDependencies {
                        $0.synchronizeWithCloudUseCase = synchronizeWithCloudUseCaseMock
                    } operation: {
                        viewModel = RootViewModel()
                        await viewModel.load()
                        expect(synchronizeWithCloudUseCaseMock.executeCallsCount) == 1
                        expect(viewModel.uiState.isLaunching) == false
                    }
                }
            }
        }
    }
}

// swiftlint:enable implicitly_unwrapped_optional
