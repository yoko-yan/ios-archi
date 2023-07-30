//
//  Created by yokoda.takayuki on 2023/07/27
//

import Combine
import Foundation
import Nimble
import Quick
import UIKit

@testable import AppFeature

class GetSeedUseCaseSpec: QuickSpec {
    override class func spec() {
        var recognizeTextRepositoryMock: RecognizeTextRepositoryMock!
        var useCase: GetSeedUseCaseImpl!
        var cancellables: [AnyCancellable] = []
        let image = UIImage(named: "seed_1541822036", in: Bundle.module, with: nil)!
        let expectedError = NSError(domain: "VNRecognizeTextRequest Error", code: -10001, userInfo: nil)

        describe("execute") {
            beforeEach {
                recognizeTextRepositoryMock = RecognizeTextRepositoryMock()
                useCase = GetSeedUseCaseImpl(recognizeTextRepository: recognizeTextRepositoryMock)
                cancellables = []
            }

            context("画像から文字が1つ以上取得できた場合") {
                beforeEach {
                    recognizeTextRepositoryMock.getHandler = { _ in
                        Just(["1541822036", "15418"])
                            .setFailureType(to: RecognizeTextError.self)
                            .eraseToAnyPublisher()
                    }
                }

                it("Seedに変換できる") {
                    waitUntil { done in
                        useCase.execute(image: image)
                            .receive(on: DispatchQueue.main)
                            .sink(receiveCompletion: { _ in
                            }, receiveValue: { seed in
                                expect(seed) == Seed(rawValue: 1541822036)
                                done()
                            })
                            .store(in: &cancellables)
                    }
                }
            }

            context("画像から文字が取得できなかった場合") {
                beforeEach {
                    recognizeTextRepositoryMock.getHandler = { _ in
                        Just([])
                            .setFailureType(to: RecognizeTextError.self)
                            .eraseToAnyPublisher()
                    }
                }

                it("Seedはnil") {
                    waitUntil(timeout: .milliseconds(100)) { done in
                        useCase.execute(image: image)
                            .receive(on: DispatchQueue.main)
                            .sink(receiveCompletion: { _ in
                            }, receiveValue: { seed in
                                expect(seed) == nil
                                done()
                            })
                            .store(in: &cancellables)
                    }
                }
            }

            context("画像解析に失敗した場合") {
                beforeEach {
                    recognizeTextRepositoryMock.getHandler = { _ in
                        Fail(error: RecognizeTextError.error(expectedError))
                            .eraseToAnyPublisher()
                    }
                }

                it("RecognizeTextErrorが返される") {
                    waitUntil(timeout: .milliseconds(100)) { done in
                        useCase.execute(image: image)
                            .receive(on: DispatchQueue.main)
                            .sink(receiveCompletion: { completion in
                                if case let .failure(error) = completion {
                                    expect(error).to(matchError(RecognizeTextError.error(expectedError)))
                                    done()
                                }
                            }, receiveValue: { _ in
                            })
                            .store(in: &cancellables)
                    }
                }
            }
        }
    }
}

class RecognizeTextRepositoryMock: RecognizeTextRepository {
    init() {}

    private(set) var getCallCount = 0
    var getHandler: ((UIImage) -> AnyPublisher<[String], RecognizeTextError>)?
    func get(image: UIImage) -> AnyPublisher<[String], RecognizeTextError> {
        getCallCount += 1
        if let getHandler {
            return getHandler(image)
        }
        fatalError()
    }
}
