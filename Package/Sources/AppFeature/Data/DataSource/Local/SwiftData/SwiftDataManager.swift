import Foundation
import SwiftData

@MainActor
final class SwiftDataManager {
    static let shared = SwiftDataManager()
    private(set) var container: ModelContainer!

    // 最後に初期化した時の設定を記録
    private var lastInitializedWithCloudKitEnabled: Bool?

    private var iCloudSyncEnabled: Bool {
        // デフォルト値をtrueに設定
        if !UserDefaults.standard.dictionaryRepresentation().keys.contains("iCloudSyncEnabled") {
            UserDefaults.standard.set(true, forKey: "iCloudSyncEnabled")
        }
        return UserDefaults.standard.bool(forKey: "iCloudSyncEnabled")
    }

    private init() {
        setupContainer()
    }

    /// フォアグラウンド復帰時に設定変更をチェックして必要なら再初期化
    func reinitializeIfNeeded() {
        let currentSetting = iCloudSyncEnabled
        let pendingReinitialization = UserDefaults.standard.bool(forKey: "pendingModelContainerReinitialization")

        // 設定が変更されている場合のみ再初期化
        if lastInitializedWithCloudKitEnabled != currentSetting {
            print("🔄 iCloud sync setting changed, reinitializing ModelContainer...")
            print("   - Previous: \(lastInitializedWithCloudKitEnabled.map(String.init) ?? "none")")
            print("   - Current: \(currentSetting)")

            // 再初期化開始を通知
            NotificationCenter.default.post(name: .modelContainerReinitializationStarted, object: nil)

            setupContainer()

            // 再初期化完了を通知
            NotificationCenter.default.post(name: .modelContainerReinitializationCompleted, object: nil)
            print("✅ ModelContainer reinitialization completed")
        } else if pendingReinitialization {
            // 設定変更がないが、保留中の再初期化がある場合（既に設定が反映されている場合）
            print("ℹ️ No configuration change needed, clearing pending flag")
            NotificationCenter.default.post(name: .modelContainerReinitializationCompleted, object: nil)
        }
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
            lastInitializedWithCloudKitEnabled = iCloudSyncEnabled
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
                lastInitializedWithCloudKitEnabled = false
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
                    lastInitializedWithCloudKitEnabled = nil
                    print("✅ In-memory storage initialized (⚠️ data will not persist)")
                } catch {
                    fatalError("❌ Failed to create ModelContainer: \(error)")
                }
            }
        }
    }
}

extension Notification.Name {
    static let modelContainerReinitializationStarted = Notification.Name("modelContainerReinitializationStarted")
    static let modelContainerReinitializationCompleted = Notification.Name("modelContainerReinitializationCompleted")
}
