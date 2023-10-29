//
//  Created by yokoda.takayuki on 2023/07/27
//

import Combine
import Foundation
import Nimble
import Quick
import UIKit

@testable import AppFeature

class GetCoordinatesUseCaseSpec: AsyncSpec {
    override class func spec() {
        var recognizedTextsRepositoryMock: RecognizedTextsRepositoryMock!
        var useCase: GetCoordinatesFromImageUseCase!
        let image = UIImage(resource: .coordinates318631143)
        let expectedError = NSError(domain: "VNRecognizeTextRequest Error", code: -10001, userInfo: nil)

        describe("execute") {
            beforeEach {
                recognizedTextsRepositoryMock = RecognizedTextsRepositoryMock()
                useCase = GetCoordinatesFromImageUseCase(recognizeTextRepository: recognizedTextsRepositoryMock)
            }

            context("画像から正しい形式で取得できた場合") {
                beforeEach {
                    recognizedTextsRepositoryMock.getHandler = { _ in
                        ["318,63,1143", "8,6,z13"]
                    }
                }

                it("Coordinatesに変換できる") {
                    let coordinates = try await useCase.execute(image: image)
                    expect(coordinates) == Coordinates(x: 318, y: 63, z: 1143)
                }
            }

            context("画像から正しい形式（空白含む）で取得できた場合") {
                beforeEach {
                    recognizedTextsRepositoryMock.getHandler = { _ in
                        ["318, 63, 1143", "8, 6, 13"]
                    }
                }

                it("Coordinatesに変換できる") {
                    let coordinates = try await useCase.execute(image: image)
                    expect(coordinates) == Coordinates(x: 318, y: 63, z: 1143)
                }
            }

            context("画像から文字が取得できなかった場合") {
                beforeEach {
                    recognizedTextsRepositoryMock.getHandler = { _ in
                        []
                    }
                }

                it("Coordinatesはnil") {
                    let coordinates = try await useCase.execute(image: image)
                    expect(coordinates) == nil
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
                        let _ = try await useCase.execute(image: image)
                    } catch {
                        expect(error).to(matchError(RecognizeTextLocalRequestError.error(expectedError)))
                    }
                }
            }
        }
    }
}

private final class RecognizedTextsRepositoryMock: RecognizedTextsRepository {
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
