import Dependencies
import Foundation

// MARK: - CameraSettingsRepository

extension DependencyValues {
    var cameraSettingsRepository: any CameraSettingsRepository {
        get { self[CameraSettingsRepositoryKey.self] }
        set { self[CameraSettingsRepositoryKey.self] = newValue }
    }
}

private enum CameraSettingsRepositoryKey: DependencyKey {
    static let liveValue: any CameraSettingsRepository = CameraSettingsRepositoryImpl()
}

// MARK: - GetCameraSettingsUseCase

extension DependencyValues {
    var getCameraSettingsUseCase: any GetCameraSettingsUseCase {
        get { self[GetCameraSettingsUseCaseKey.self] }
        set { self[GetCameraSettingsUseCaseKey.self] = newValue }
    }
}

private enum GetCameraSettingsUseCaseKey: DependencyKey {
    static let liveValue: any GetCameraSettingsUseCase = GetCameraSettingsUseCaseImpl()
}

// MARK: - SaveCameraSettingsUseCase

extension DependencyValues {
    var saveCameraSettingsUseCase: any SaveCameraSettingsUseCase {
        get { self[SaveCameraSettingsUseCaseKey.self] }
        set { self[SaveCameraSettingsUseCaseKey.self] = newValue }
    }
}

private enum SaveCameraSettingsUseCaseKey: DependencyKey {
    static let liveValue: any SaveCameraSettingsUseCase = SaveCameraSettingsUseCaseImpl()
}
