import Foundation
import SwiftData
import CloudKit

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
        checkCloudKitAvailability()
        setupContainer()
    }

    /// CloudKitの利用可能性をチェック
    private func checkCloudKitAvailability() {
        Task {
            do {
                let bundleID = Bundle.main.bundleIdentifier ?? "com.runpany.ios-archi"
                let containerID = CKContainer.ID("iCloud.\(bundleID)")
                let container = CKContainer(identifier: containerID)

                let status = try await container.accountStatus()
                switch status {
                case .available:
                    print("✅ CloudKit account available")
                case .noAccount:
                    print("⚠️ CloudKit: No iCloud account")
                case .restricted:
                    print("⚠️ CloudKit: Account restricted")
                case .couldNotDetermine:
                    print("⚠️ CloudKit: Could not determine account status")
                case .temporarilyUnavailable:
                    print("⚠️ CloudKit: Temporarily unavailable")
                @unknown default:
                    print("⚠️ CloudKit: Unknown account status")
                }
            } catch {
                print("⚠️ CloudKit availability check failed: \(error)")
            }
        }
    }

    /// フォアグラウンド復帰時に設定変更をチェックして必要なら再初期化
    func reinitializeIfNeeded() {
        let currentSetting = iCloudSyncEnabled
        let pendingReinitialization = UserDefaults.standard.bool(forKey: "pendingModelContainerReinitialization")

        // 初回起動時（lastInitializedWithCloudKitEnabled が nil）は何もしない
        guard let lastSetting = lastInitializedWithCloudKitEnabled else {
            print("ℹ️ Initial app launch, skipping reinitialization check")
            // 初回起動時でも、保留中のフラグがあればクリア
            if pendingReinitialization {
                print("ℹ️ Clearing pending reinitialization flag on initial launch")
                NotificationCenter.default.post(name: .modelContainerReinitializationCompleted, object: nil)
            }
            return
        }

        // 設定が変更されている場合のみ再初期化
        if lastSetting != currentSetting {
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
                // Bundle Identifierから明示的にコンテナIDを取得
                let bundleID = Bundle.main.bundleIdentifier ?? "com.runpany.ios-archi"
                let containerIdentifier = "iCloud.\(bundleID)"

                print("ℹ️ Setting up CloudKit sync")
                print("   - Container ID: \(containerIdentifier)")

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
            print("   - CloudKit database: \(config.cloudKitDatabase)")
            if let url = config.url {
                print("   - Store URL: \(url.path)")
            }
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
