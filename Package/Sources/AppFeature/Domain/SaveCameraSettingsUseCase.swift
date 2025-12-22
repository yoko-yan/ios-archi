import Foundation

/// カメラ設定を保存するUseCaseプロトコル
protocol SaveCameraSettingsUseCase: Sendable {
    /// カメラ設定を保存
    func execute(_ settings: CameraSettings) async throws
}

/// SaveCameraSettingsUseCaseの実装
struct SaveCameraSettingsUseCaseImpl: SaveCameraSettingsUseCase {
    private let repository: any CameraSettingsRepository

    init(repository: any CameraSettingsRepository = CameraSettingsRepositoryImpl()) {
        self.repository = repository
    }

    func execute(_ settings: CameraSettings) async throws {
        try await repository.save(settings)
    }
}
