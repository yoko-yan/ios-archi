import Foundation

/// カメラ設定のリポジトリプロトコル
protocol CameraSettingsRepository: Sendable {
    /// 設定を取得
    func get() async throws -> CameraSettings

    /// 設定を保存
    func save(_ settings: CameraSettings) async throws

    /// 設定をリセット
    func reset() async throws
}

/// CameraSettingsRepositoryの実装
struct CameraSettingsRepositoryImpl: CameraSettingsRepository {
    private let userDefaults: UserDefaults
    private let key = "camera_settings"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func get() async throws -> CameraSettings {
        guard let data = userDefaults.data(forKey: key),
              let settings = try? JSONDecoder().decode(CameraSettings.self, from: data)
        else {
            return .default
        }
        return settings
    }

    func save(_ settings: CameraSettings) async throws {
        let data = try JSONEncoder().encode(settings)
        userDefaults.set(data, forKey: key)
    }

    func reset() async throws {
        userDefaults.removeObject(forKey: key)
    }
}
