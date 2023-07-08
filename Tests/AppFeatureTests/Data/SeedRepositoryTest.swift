//
//  Created by apla on 2023/07/08
//

@testable import AppFeature
import Nimble
import Quick
import UIKit

final class SeedRepositoryTest: QuickSpec {
    override class func spec() {
        describe("get(image:)") {
            context("読み取り可能な画像の場合") {
                it("シード値を取得できる") {
                    var actualSeed: Seed!
                    let image = UIImage(named: "seed_1541822036", in: Bundle.module, with: nil)

                    let repository = SeedRepository()
                    repository.get(image: image!) { result in
                        switch result {
                        case let .success(seed):
                            actualSeed = seed
                        case .failure:
                            break
                        }
                        expect(actualSeed.rawValue).toEventually(equal(1541822036))
                    }
                }
            }
        }
    }
}
