// swiftlint:disable implicitly_unwrapped_optional

import Nimble
import Quick
import UIKit

@testable import AppFeature

class GetSeedFromImageUseCaseSpec: AsyncSpec {
    override class func spec() {
        var recognizedTextsRepositoryMock: RecognizedTextsRepositoryMock!
        var useCase: GetSeedFromImageUseCaseImpl!
        let image = UIImage(resource: .seed1541822036)
        let expectedError = NSError(domain: "VNRecognizeTextRequest Error", code: -10001, userInfo: nil)

        describe("execute") {
            beforeEach {
                recognizedTextsRepositoryMock = RecognizedTextsRepositoryMock()
                useCase = GetSeedFromImageUseCaseImpl(recognizedTextsRepository: recognizedTextsRepositoryMock)
            }

            context("画像から文字が1つ以上取得できた場合") {
                beforeEach {
                    recognizedTextsRepositoryMock.getHandler = { _ in
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
                    recognizedTextsRepositoryMock.getHandler = { _ in
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
                    recognizedTextsRepositoryMock.getHandler = { _ in
                        throw RecognizeTextLocalRequestError.error(expectedError)
                    }
                }

                it("RecognizeTextErrorが返される") {
                    do {
                        _ = try await useCase.execute(image: image)
                    } catch {
                        expect(error).to(matchError(RecognizeTextLocalRequestError.error(expectedError)))
                    }
                }
            }
        }
    }
}

private final class RecognizedTextsRepositoryMock: RecognizedTextsRepository {
    private(set) var getCallCount = 0
    var getHandler: ((UIImage) async throws -> [String])?

    func get(image: UIImage) async throws -> [String] {
        getCallCount += 1
        if let getHandler {
            return try await getHandler(image)
        }
        fatalError()
    }

    func get(image: UIImage, settings: CameraSettings) async throws -> [String] {
        try await get(image: image)
    }
}

// swiftlint:enable implicitly_unwrapped_optional
