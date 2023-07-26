//
//  Created by apla on 2023/07/08
//

import Combine
import Nimble
import Quick
import UIKit

@testable import AppFeature

final class SeedRepositorySpec: QuickSpec {
    override class func spec() {
        var cancellables: [AnyCancellable] = []

        describe("get(image:)") {
            context("読み取り可能な画像の場合") {
                it("シード値を取得できる") {
                    let image = UIImage(named: "seed_1541822036", in: Bundle.module, with: nil)

                    SeedRepository().get(image: image!)
                        .receive(on: DispatchQueue.main)
                        .sink(receiveCompletion: { _ in
                        }, receiveValue: { seed in
                            expect(seed?.rawValue).toEventually(equal(1541822036))
                        })
                        .store(in: &cancellables)
                }
            }

//            context("読み取り可能な画像の場合") {
//                it("シード値を取得できる") {
//                    let image = UIImage(named: "seed_1541822036", in: Bundle.module, with: nil)
//
//                    let repository = SeedRepository()
//                    repository.get(image: image!) { result in
//                        switch result {
//                        case let .success(seed):
//                            expect(seed?.rawValue).toEventually(equal(1541822036))
//                        case .failure:
//                            break
//                        }
//                    }
//                }
//            }
        }
    }
}
