//
//  Created by yokoda.takayuki on 2023/07/27
//

import Combine
import Foundation
import Nimble
import Quick
import UIKit

@testable import AppFeature

class GetSeedUseCaseSpec: AsyncSpec {
    override class func spec() {
        var recognizedTextsRepositoryMock: RecognizedTextsRepositoryMock!
        var useCase: GetSeedUseCaseImpl!
        let image = UIImage(named: "seed_1541822036", in: Bundle.module, with: nil)!
        let expectedError = NSError(domain: "VNRecognizeTextRequest Error", code: -10001, userInfo: nil)

        describe("execute") {
            beforeEach {
                recognizedTextsRepositoryMock = RecognizedTextsRepositoryMock()
                useCase = GetSeedUseCaseImpl(recognizedTextsRepository: recognizedTextsRepositoryMock)
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

// class GetSeedUseCaseSpec: QuickSpec {
//    override class func spec() {
//        var recognizedTextsRepositoryMock: RecognizedTextsRepositoryMock!
//        var useCase: GetSeedUseCaseImpl!
//        var cancellables: [AnyCancellable] = []
//        let image = UIImage(named: "seed_1541822036", in: Bundle.module, with: nil)!
//        let expectedError = NSError(domain: "VNRecognizeTextRequest Error", code: -10001, userInfo: nil)
//
//        describe("execute") {
//            beforeEach {
//                recognizedTextsRepositoryMock = RecognizedTextsRepositoryMock()
//                useCase = GetSeedUseCaseImpl(recognizedTextsRepository: recognizedTextsRepositoryMock)
//                cancellables = []
//            }
//
//            context("画像から文字が1つ以上取得できた場合") {
//                beforeEach {
//                    recognizedTextsRepositoryMock.getHandler = { _ in
//                        Just(["1541822036", "15418"])
//                            .setFailureType(to: RecognizeTextError.self)
//                            .eraseToAnyPublisher()
//                    }
//                }
//
//                it("Seedに変換できる") {
//                    waitUntil { done in
//                        useCase.execute(image: image)
//                            .receive(on: DispatchQueue.main)
//                            .sink(receiveCompletion: { _ in
//                            }, receiveValue: { seed in
//                                expect(seed) == Seed(rawValue: 1541822036)
//                                done()
//                            })
//                            .store(in: &cancellables)
//                    }
//                }
//            }
//
//            context("画像から文字が取得できなかった場合") {
//                beforeEach {
//                    recognizedTextsRepositoryMock.getHandler = { _ in
//                        Just([])
//                            .setFailureType(to: RecognizeTextError.self)
//                            .eraseToAnyPublisher()
//                    }
//                }
//
//                it("Seedはnil") {
//                    waitUntil(timeout: .milliseconds(100)) { done in
//                        useCase.execute(image: image)
//                            .receive(on: DispatchQueue.main)
//                            .sink(receiveCompletion: { _ in
//                            }, receiveValue: { seed in
//                                expect(seed) == nil
//                                done()
//                            })
//                            .store(in: &cancellables)
//                    }
//                }
//            }
//
//            context("画像解析に失敗した場合") {
//                beforeEach {
//                    recognizedTextsRepositoryMock.getHandler = { _ in
//                        Fail(error: RecognizeTextError.error(expectedError))
//                            .eraseToAnyPublisher()
//                    }
//                }
//
//                it("RecognizeTextErrorが返される") {
//                    waitUntil(timeout: .milliseconds(100)) { done in
//                        useCase.execute(image: image)
//                            .receive(on: DispatchQueue.main)
//                            .sink(receiveCompletion: { completion in
//                                if case let .failure(error) = completion {
//                                    expect(error).to(matchError(RecognizeTextError.error(expectedError)))
//                                    done()
//                                }
//                            }, receiveValue: { _ in
//                            })
//                            .store(in: &cancellables)
//                    }
//                }
//            }
//        }
//    }
// }
//
// class RecognizedTextsRepositoryMock: RecognizedTextsRepository {
//    init() {}
//
//    private(set) var getCallCount = 0
//    var getHandler: ((UIImage) -> AnyPublisher<[String], RecognizeTextError>)?
//    func get(image: UIImage) -> AnyPublisher<[String], RecognizeTextError> {
//        getCallCount += 1
//        if let getHandler {
//            return getHandler(image)
//        }
//        fatalError()
//    }
// }
