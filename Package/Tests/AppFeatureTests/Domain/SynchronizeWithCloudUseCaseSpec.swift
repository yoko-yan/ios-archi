//// swiftlint:disable implicitly_unwrapped_optional
//
// import Core
// import CoreData
// import Nimble
// import Quick
//
// @testable import AppFeature
//
// final class SynchronizeWithCloudUseCaseSpec: AsyncSpec {
//    override class func spec() {
//        var useCase: SynchronizeWithCloudUseCase!
//        var isCloudKitContainerAvailableUseCaseMock: IsCloudKitContainerAvailableUseCaseMock!
//        var itemsRepositoryMock: ItemsRepositoryMock!
//
//        describe("execute") {
//            beforeEach {
//                useCase = SynchronizeWithCloudUseCaseImpl()
//                isCloudKitContainerAvailableUseCaseMock = IsCloudKitContainerAvailableUseCaseMock()
//                InjectedValues[\.isCloudKitContainerAvailableUseCase] = isCloudKitContainerAvailableUseCaseMock
//                itemsRepositoryMock = ItemsRepositoryMock()
//                InjectedValues[\.itemsRepository] = itemsRepositoryMock
//            }
//
//            context("iCloudの設定なし") {
//                beforeEach {
//                    isCloudKitContainerAvailableUseCaseMock.executeClosure = {
//                        false
//                    }
//                }
//
//                it("スプラッシュ解除") {
//                    let result = try await useCase.execute()
//                    expect(result) == false
//                }
//            }
//
//            context("iCloudの設定あり") {
//                beforeEach {
//                    isCloudKitContainerAvailableUseCaseMock.executeClosure = {
//                        true
//                    }
//                    itemsRepositoryMock.fetchAllClosure = {
//                        []
//                    }
//                }
//
//                context("NotificationCenterの通知が来ないので") {
//                    it("タイムアウトしてスプラッシュ解除") {
//                        let result = try await useCase.execute()
//                        expect(result) == false
//                    }
//                }
//            }
//        }
//    }
// }
