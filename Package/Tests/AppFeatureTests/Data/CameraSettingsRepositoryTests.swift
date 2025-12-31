import Foundation
import Testing

@testable import AppFeature

@Suite("CameraSettings Repository Tests")
struct CameraSettingsRepositoryTests {
    @Test("デフォルト設定を返す")
    func defaultSettings() async throws {
        // テスト用のUserDefaultsを使用
        let userDefaults = UserDefaults(suiteName: "test.CameraSettingsRepositoryTests.default")!
        userDefaults.removePersistentDomain(forName: "test.CameraSettingsRepositoryTests.default")

        let repository = CameraSettingsRepositoryImpl(userDefaults: userDefaults)
        let settings = try await repository.get()

        #expect(settings == CameraSettings.default)
    }

    @Test("設定を保存して読み込める")
    func saveAndLoad() async throws {
        // テスト用のUserDefaultsを使用
        let userDefaults = UserDefaults(suiteName: "test.CameraSettingsRepositoryTests.saveLoad")!
        userDefaults.removePersistentDomain(forName: "test.CameraSettingsRepositoryTests.saveLoad")

        let repository = CameraSettingsRepositoryImpl(userDefaults: userDefaults)
        var settings = CameraSettings.default
        settings.flashEnabled = true
        settings.gridEnabled = true
        settings.ocrRecognitionLevel = .fast

        try await repository.save(settings)
        let loaded = try await repository.get()

        #expect(loaded.flashEnabled == true)
        #expect(loaded.gridEnabled == true)
        #expect(loaded.ocrRecognitionLevel == .fast)
    }

    @Test("設定をリセットできる")
    func testReset() async throws {
        // テスト用のUserDefaultsを使用
        let userDefaults = UserDefaults(suiteName: "test.CameraSettingsRepositoryTests.reset")!
        userDefaults.removePersistentDomain(forName: "test.CameraSettingsRepositoryTests.reset")

        let repository = CameraSettingsRepositoryImpl(userDefaults: userDefaults)
        var settings = CameraSettings.default
        settings.flashEnabled = true

        try await repository.save(settings)
        try await repository.reset()
        let loaded = try await repository.get()

        // リセット後はデフォルト設定が返される
        #expect(loaded == CameraSettings.default)
    }

    @Test("JSONシリアライズ・デシリアライズが正常に動作")
    func jSONSerialization() throws {
        let settings = CameraSettings.default
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let data = try encoder.encode(settings)
        let decoded = try decoder.decode(CameraSettings.self, from: data)

        #expect(decoded == settings)
    }

    @Test("バリデーション: 空の言語配列はエラー")
    func validationEmptyLanguages() {
        var settings = CameraSettings.default
        settings.ocrLanguages = []

        let result = settings.validate()

        switch result {
        case .valid:
            Issue.record("空の言語配列はバリデーションエラーになるべき")
        case let .invalid(errors):
            #expect(errors.contains(.emptyLanguages))
        }
    }

    @Test("バリデーション: 不正な圧縮サイズはエラー")
    func validationInvalidCompressionSize() {
        var settings = CameraSettings.default
        settings.imageCompressionSizeKB = -100.0

        let result = settings.validate()

        switch result {
        case .valid:
            Issue.record("負の圧縮サイズはバリデーションエラーになるべき")
        case let .invalid(errors):
            #expect(errors.contains(.invalidCompressionSize))
        }
    }

    @Test("バリデーション: 不正なズーム倍率はエラー")
    func validationInvalidZoomFactor() {
        var settings = CameraSettings.default
        settings.zoomFactor = 10.0

        let result = settings.validate()

        switch result {
        case .valid:
            Issue.record("範囲外のズーム倍率はバリデーションエラーになるべき")
        case let .invalid(errors):
            #expect(errors.contains(.invalidZoomFactor))
        }
    }

    @Test("バリデーション: 正常な設定はバリデーションパス")
    func validationValid() {
        let settings = CameraSettings.default

        let result = settings.validate()

        switch result {
        case .valid:
            // 期待通り
            break
        case .invalid:
            Issue.record("デフォルト設定はバリデーションをパスすべき")
        }
    }
}
