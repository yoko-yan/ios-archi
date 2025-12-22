import Dependencies
import Testing
@testable import AppFeature

@Suite("GetCameraSettingsUseCase Tests")
struct GetCameraSettingsUseCaseTests {
    @Test("設定を取得できる")
    func testGetSettings() async throws {
        // テスト用のモックRepository
        let mockRepository = MockCameraSettingsRepository()

        try await withDependencies {
            $0.cameraSettingsRepository = mockRepository
        } operation: {
            let useCase = GetCameraSettingsUseCaseImpl(repository: mockRepository)
            let settings = try await useCase.execute()

            #expect(settings == CameraSettings.default)
        }
    }

    @Test("Repositoryからエラーが発生した場合は伝播する")
    func testGetSettingsError() async throws {
        // テスト用のエラーを返すRepository
        let errorRepository = ErrorCameraSettingsRepository()

        try await withDependencies {
            $0.cameraSettingsRepository = errorRepository
        } operation: {
            let useCase = GetCameraSettingsUseCaseImpl(repository: errorRepository)

            do {
                _ = try await useCase.execute()
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
