@testable import AppFeature
import Dependencies
import Testing

@Suite("SaveCameraSettingsUseCase Tests")
struct SaveCameraSettingsUseCaseTests {
    @Test("設定を保存できる")
    func saveSettings() async throws {
        // テスト用のモックRepository
        let mockRepository = MockCameraSettingsRepository()

        try await withDependencies {
            $0.cameraSettingsRepository = mockRepository
        } operation: {
            let useCase = SaveCameraSettingsUseCaseImpl(repository: mockRepository)
            var settings = CameraSettings.default
            settings.flashEnabled = true

            // エラーなく保存できること
            try await useCase.execute(settings)
        }
    }

    @Test("Repositoryからエラーが発生した場合は伝播する")
    func saveSettingsError() async throws {
        // テスト用のエラーを返すRepository
        let errorRepository = ErrorCameraSettingsRepository()

        try await withDependencies {
            $0.cameraSettingsRepository = errorRepository
        } operation: {
            let useCase = SaveCameraSettingsUseCaseImpl(repository: errorRepository)
            let settings = CameraSettings.default

            do {
                try await useCase.execute(settings)
                Issue.record("エラーが発生すべき")
            } catch {
                // 期待通りエラーが伝播
                #expect(error is TestError)
            }
        }
    }
}

// MARK: - Mock Repository

private struct MockCameraSettingsRepository: CameraSettingsRepository {
    func get() async throws -> CameraSettings {
        .default
    }

    func save(_: CameraSettings) async throws {
        // モックなので何もしない
    }

    func reset() async throws {
        // モックなので何もしない
    }
}

private struct ErrorCameraSettingsRepository: CameraSettingsRepository {
    func get() async throws -> CameraSettings {
        throw TestError.mockError
    }

    func save(_: CameraSettings) async throws {
        throw TestError.mockError
    }

    func reset() async throws {
        throw TestError.mockError
    }
}

private enum TestError: Error {
    case mockError
}
