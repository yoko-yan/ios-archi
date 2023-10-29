//
//  Created by yokoda.takayuki on 2023/07/27
//

import Combine
import Dependencies
import Foundation
import Nimble
import Quick
import UIKit

@testable import AppFeature

class GetSeed2UseCaseSpec: AsyncSpec {
    override class func spec() {
        var newRecognizedTextsRepositoryMock: NewRecognizedTextsRepositoryMock!
        var useCase: GetSeedFromImage2UseCaseImpl!
        let image = UIImage(resource: .seed1541822036)
        let expectedError = NSError(domain: "VNRecognizeTextRequest Error", code: -10001, userInfo: nil)

        describe("execute") {
            beforeEach {
                newRecognizedTextsRepositoryMock = NewRecognizedTextsRepositoryMock()
                withDependencies {
                    $0.newRecognizedTextsRepository = newRecognizedTextsRepositoryMock
                    $0.extractSeedUseCase = GetSeedFromTextUseCaseImpl()
                } operation: {
                    useCase = GetSeedFromImage2UseCaseImpl()
                }
            }

            context("画像から文字が1つ以上取得できた場合") {
                beforeEach {
                    newRecognizedTextsRepositoryMock.getHandler = { _ in
                        ["1541822036", "15418"]
                    }
                }

                it("Seedに変換できる") {
                    let seed = try await useCase.execute(image: image)
                    expect(seed) == Seed(rawValue: 1541822036)
                }
            }

            context("画像から文字が取得できなかった場合") {
                beforeEach {
                    newRecognizedTextsRepositoryMock.getHandler = { _ in
                        []
                    }
                }

                it("Seedはnil") {
                    let seed = try await useCase.execute(image: image)
                    expect(seed) == nil
                }
            }

            context("画像解析に失敗した場合") {
                beforeEach {
                    newRecognizedTextsRepositoryMock.getHandler = { _ in
                        throw RecognizeTextLocalRequestError.error(expectedError)
                    }
                }

                it("RecognizeTextErrorが返される") {
                    do {
                        let _ = try await useCase.execute(image: image)
                    } catch {
                        expect(error).to(matchError(RecognizeTextLocalRequestError.error(expectedError)))
                    }
                }
            }
        }
    }
}

private final class NewRecognizedTextsRepositoryMock: NewRecognizedTextsRepository {
    init() {}

    private(set) var getCallCount = 0
    var getHandler: ((UIImage) async throws -> [String])?
    func get(image: UIImage) async throws -> [String] {
        getCallCount += 1
        if let getHandler {
            return try await getHandler(image)
        }
        fatalError()
    }
}

extension NewRecognizedTextsRepositoryMock: @unchecked Sendable {}
