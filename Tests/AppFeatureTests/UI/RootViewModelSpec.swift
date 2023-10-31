//
//  Created by apla on 2023/10/31
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
                    isiCloudUseCaseMock.executeHandler = { true }
                    synchronizeWithCloudUseCaseMock.executeHandler = { true }
                }

                it("The app launches successfully.") { @MainActor in
                    await viewModel.load()
                    expect(isiCloudUseCaseMock.executeCallCount) == 1
                    expect(synchronizeWithCloudUseCaseMock.executeCallCount) == 1
                    expect(viewModel.uiState.isLaunching) == true
                }
            }
        }
    }
}

private final class IsiCloudUseCaseMock: IsiCloudUseCase {
    private(set) var executeCallCount = 0
    var executeHandler: (() -> Bool)?
    func execute() -> Bool {
        executeCallCount += 1
        if let executeHandler {
            return executeHandler()
        }
        fatalError()
    }
}

private final class SynchronizeWithCloudUseCaseMock: SynchronizeWithCloudUseCase {
    private(set) var executeCallCount = 0
    var executeHandler: (() async throws -> Bool)?
    func execute() async throws -> Bool {
        executeCallCount += 1
        if let executeHandler {
            return try await executeHandler()
        }
        fatalError()
    }
}
