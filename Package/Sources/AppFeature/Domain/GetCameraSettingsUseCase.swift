import Foundation

/// カメラ設定を取得するUseCaseプロトコル
protocol GetCameraSettingsUseCase: Sendable {
    /// カメラ設定を取得
    func execute() async throws -> CameraSettings
}

/// GetCameraSettingsUseCaseの実装
struct GetCameraSettingsUseCaseImpl: GetCameraSettingsUseCase {
    private let repository: any CameraSettingsRepository

    init(repository: any CameraSettingsRepository = CameraSettingsRepositoryImpl()) {
        self.repository = repository
    }

    func execute() async throws -> CameraSettings {
        try await repository.get()
    }
}
