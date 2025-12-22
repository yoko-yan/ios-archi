import Foundation
import SwiftData

@MainActor
final class SwiftDataManager {
    static let shared = SwiftDataManager()
    private(set) var container: ModelContainer!

    private var iCloudSyncEnabled: Bool {
        // デフォルト値をtrueに設定
        if !UserDefaults.standard.dictionaryRepresentation().keys.contains("iCloudSyncEnabled") {
            UserDefaults.standard.set(true, forKey: "iCloudSyncEnabled")
        }
        return UserDefaults.standard.bool(forKey: "iCloudSyncEnabled")
    }

    private init() {
        setupContainer()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSyncSettingChanged),
            name: .iCloudSyncSettingChanged,
            object: nil
        )
    }

    private func setupContainer() {
        // SwiftData専用のストア名を使用（既存のCoreDataストアとの競合を避ける）
        let storeName = "SwiftDataStore"

        do {
            let config: ModelConfiguration
            if iCloudSyncEnabled {
                // CloudKit同期を有効化
                config = ModelConfiguration(
                    storeName,
                    cloudKitDatabase: .automatic
                )
            } else {
                // ローカルのみ
                config = ModelConfiguration(
                    storeName,
                    cloudKitDatabase: .none
                )
            }

            container = try ModelContainer(
                for: ItemModel.self, WorldModel.self,
                configurations: config
            )
            print("✅ ModelContainer initialized successfully")
            print("   - Store name: \(storeName)")
            print("   - CloudKit enabled: \(iCloudSyncEnabled)")
        } catch {
            print("⚠️ Failed to initialize ModelContainer")
            print("⚠️ Error details: \(error)")
            print("⚠️ Error localized: \(error.localizedDescription)")

            // フォールバック: シンプルなローカルストレージ（CloudKit無効）
            print("⚠️ Attempting fallback to local-only storage...")
            do {
                let config = ModelConfiguration(
                    storeName,
                    cloudKitDatabase: .none
                )
                container = try ModelContainer(
                    for: ItemModel.self, WorldModel.self,
                    configurations: config
                )
                print("✅ Fallback successful - using local-only storage")
            } catch {
                print("❌ Fallback failed: \(error)")

                // 最終手段: インメモリストレージ
                print("⚠️ Attempting in-memory storage as last resort...")
                do {
                    let config = ModelConfiguration(isStoredInMemoryOnly: true)
                    container = try ModelContainer(
                        for: ItemModel.self, WorldModel.self,
                        configurations: config
                    )
                    print("✅ In-memory storage initialized (⚠️ data will not persist)")
                } catch {
                    fatalError("❌ Failed to create ModelContainer: \(error)")
                }
            }
        }
    }

    @objc private func handleSyncSettingChanged() {
        // 注意: 設定変更後はアプリ再起動が必要
        setupContainer()
    }
}

extension Notification.Name {
    static let iCloudSyncSettingChanged = Notification.Name("iCloudSyncSettingChanged")
}
