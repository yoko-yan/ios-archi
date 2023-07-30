////
////  Created by yokoda.takayuki on 2023/07/27
////
//
// import Combine
// import Foundation
// import Nimble
// import Quick
// import UIKit
//
// @testable import AppFeature
//
// class GetCoordinatesUseCaseSpec: QuickSpec {
//    override class func spec() {
//        var useCase: GetCoordinatesUseCaseImpl!
//        let image = UIImage(named: "coordinates_318_63_1143", in: Bundle.module, with: nil)!
//        var cancellables: [AnyCancellable] = []
//
//        describe("execute") {
//            beforeEach {
//                useCase = GetCoordinatesUseCaseImpl()
//            }
//
//            context("画像から文字が1つ以上取得できた場合") {
//                it("Coordinatesに変換できる") {
//                    waitUntil { done in
//                        useCase.execute(image: image)
//                            .receive(on: DispatchQueue.main)
//                            .sink(receiveCompletion: { _ in
//                            }, receiveValue: { coordinates in
//                                expect(coordinates) == Coordinates(x: 318, y: 63, z: 1143)
//                                done()
//                            })
//                            .store(in: &cancellables)
//                    }
//                }
//            }
//        }
//    }
// }
