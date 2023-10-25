//
//  Created by yokoda.takayuki on 2023/09/05
//

import Combine
import Nimble
import Quick
import UIKit

@testable import AppFeature

final class RecognizeTextRepositorySpec: AsyncSpec {
    override class func spec() {
        describe("get(image:)") {
            context("読み取り可能な画像の場合") {
                it("テキストを取得できる") {
                    let image = UIImage(resource: .seed1541822036)

                    let texts = try await RecognizedTextsRepositoryImpl().get(image: image)
                    expect(texts.first).to(equal("世界のタイプ"))
                }
            }
        }
    }
}

// final class SeedRepositorySpec: QuickSpec {
//    override class func spec() {
//        var cancellables: [AnyCancellable] = []
//
//        context("読み取り可能な画像の場合") {
//            it("シード値を取得できる") {
//                let image = UIImage(resource: .seed1541822036)
//
//                RecognizedTextsRepositoryImpl().get(image: image)
//                    .receive(on: DispatchQueue.main)
//                    .sink(receiveCompletion: { _ in
//                    }, receiveValue: { seed in
//                        expect(seed?.rawValue).toEventually(equal(1541822036))
//                    })
//                    .store(in: &cancellables)
//            }
//        }
//    }
// }
