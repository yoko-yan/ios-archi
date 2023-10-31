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

        describe("execute") {
            beforeEach {
                isiCloudUseCaseMock = IsiCloudUseCaseMock()
                InjectedValues[\.isiCloudUseCaseMock] = isiCloudUseCaseMock
                synchronizeWithCloudUseCaseMock = SynchronizeWithCloudUseCaseMock()
                InjectedValues[\.synchronizeWithCloudUseCaseMock] = synchronizeWithCloudUseCaseMock
                viewModel = RootViewModel()
            }

            context("画像から文字が1つ以上取得できた場合") {
                beforeEach {
                    isiCloudUseCaseMock.executeHandler = { _ in true }
                    synchronizeWithCloudUseCaseMock.executeHandler = { _ in true }
                }

                it("Seedに変換できる") {
                    try await viewModel.load()
                    expect(error).to(matchError(RecognizeTextLocalRequestError.error(expectedError)))
                    expect(error).to(matchError(RecognizeTextLocalRequestError.error(expectedError)))
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
