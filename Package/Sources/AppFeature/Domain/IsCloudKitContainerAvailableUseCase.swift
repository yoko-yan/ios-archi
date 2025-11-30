import Dependencies
import Foundation
import Macros

@Mockable
protocol IsCloudKitContainerAvailableUseCase: Sendable {
    func execute() -> Bool
}

struct IsCloudKitContainerAvailableUseCaseImpl: IsCloudKitContainerAvailableUseCase {
    func execute() -> Bool {
        FileManager.default.ubiquityIdentityToken != nil
    }
}

// MARK: - DependencyValues

private struct IsCloudKitContainerAvailableUseCaseKey: DependencyKey {
    static let liveValue: any IsCloudKitContainerAvailableUseCase = IsCloudKitContainerAvailableUseCaseImpl()
}

extension DependencyValues {
    var isCloudKitContainerAvailableUseCase: any IsCloudKitContainerAvailableUseCase {
        get { self[IsCloudKitContainerAvailableUseCaseKey.self] }
        set { self[IsCloudKitContainerAvailableUseCaseKey.self] = newValue }
    }
}
