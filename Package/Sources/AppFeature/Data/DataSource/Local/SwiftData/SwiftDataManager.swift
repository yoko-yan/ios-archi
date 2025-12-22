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
        setupCloudKitNotifications()
    }

    /// CloudKitの同期通知を監視
    private func setupCloudKitNotifications() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("NSPersistentCloudKitContainerEventChangedNotification"),
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self else { return }
            if let userInfo = notification.userInfo,
               let eventTypeString = userInfo["event"] as? String {
                print("🔔 CloudKit event: \(eventTypeString)")
            }

            // Import完了後にデータ件数を確認
            Task { @MainActor in
                let context = ModelContext(self.container)
                let itemDescriptor = FetchDescriptor<ItemModel>()
                let worldDescriptor = FetchDescriptor<WorldModel>()

                if let itemCount = try? context.fetch(itemDescriptor).count,
                   let worldCount = try? context.fetch(worldDescriptor).count {
                    print("📊 After CloudKit event - Items: \(itemCount), Worlds: \(worldCount)")
                }
            }
        }
    }

    /// CloudKitの利用可能性をチェック
    private func checkCloudKitAvailability() {
        Task {
            do {
                let bundleID = Bundle.main.bundleIdentifier ?? "com.runpany.ios-archi"
                let containerIdentifier = "iCloud.\(bundleID)"
                let container = CKContainer(identifier: containerIdentifier)

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

            // オフ→オンの切り替えの場合、マージ処理を実行
            let switchedToCloudKit = !lastSetting && currentSetting

            setupContainer()

            // iCloud同期をオンにした場合、データマージを実行
            if switchedToCloudKit {
                Task {
                    await performCloudKitMerge()
                    // マージ完了後に通知
                    await MainActor.run {
                        NotificationCenter.default.post(name: .modelContainerReinitializationCompleted, object: nil)
                        print("✅ ModelContainer reinitialization completed (with merge)")
                    }
                }
            } else {
                // マージ不要の場合はすぐに完了通知
                NotificationCenter.default.post(name: .modelContainerReinitializationCompleted, object: nil)
                print("✅ ModelContainer reinitialization completed")
            }
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
            print("   - Store URL: \(config.url.path)")
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

    /// iCloud同期オン時のデータマージ処理
    /// iCloudのデータを正として、ローカルデータとマージする
    private func performCloudKitMerge() async {
        print("🔄 Starting CloudKit merge process...")
        print("   - iCloud data will be treated as source of truth")
        print("   - Local data will be merged based on ID and updatedAt")
        print("   - Waiting for CloudKit sync to complete...")

        // SwiftDataがCloudKitから同期するまで待つ
        // CloudKitからのダウンロードには時間がかかる場合がある
        try? await Task.sleep(nanoseconds: 5_000_000_000) // 5秒待機

        print("ℹ️ Starting merge operation after sync delay")
        let context = ModelContext(container)

        do {
            // 全ItemModelを取得してID別にグループ化
            let itemDescriptor = FetchDescriptor<ItemModel>(
                sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
            )
            let allItems = try context.fetch(itemDescriptor)
            print("ℹ️ Fetched \(allItems.count) items from local store")

            // IDでグループ化して重複をチェック
            let groupedItems = Dictionary(grouping: allItems, by: { $0.id })
            var duplicateCount = 0
            var itemsKept = 0
            var itemsRemoved = 0

            for (id, items) in groupedItems {
                if items.count > 1 {
                    print("⚠️ Found duplicate items with ID: \(id) (count: \(items.count))")
                    // updatedAtが最新のもの以外を削除（iCloudデータを優先）
                    let sorted = items.sorted { $0.updatedAt > $1.updatedAt }
                    print("   - Keeping newest: updatedAt=\(sorted.first!.updatedAt)")
                    for item in sorted.dropFirst() {
                        print("   - Removing older duplicate: updatedAt=\(item.updatedAt)")
                        context.delete(item)
                        itemsRemoved += 1
                        duplicateCount += 1
                    }
                    itemsKept += 1
                } else {
                    itemsKept += 1
                }
            }

            // 全WorldModelを取得してID別にグループ化
            let worldDescriptor = FetchDescriptor<WorldModel>(
                sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
            )
            let allWorlds = try context.fetch(worldDescriptor)
            print("ℹ️ Fetched \(allWorlds.count) worlds from local store")

            let groupedWorlds = Dictionary(grouping: allWorlds, by: { $0.id })
            var worldsKept = 0
            var worldsRemoved = 0

            for (id, worlds) in groupedWorlds {
                if worlds.count > 1 {
                    print("⚠️ Found duplicate worlds with ID: \(id) (count: \(worlds.count))")
                    // updatedAtが最新のもの以外を削除（iCloudデータを優先）
                    let sorted = worlds.sorted { $0.updatedAt > $1.updatedAt }
                    print("   - Keeping newest: updatedAt=\(sorted.first!.updatedAt)")
                    for world in sorted.dropFirst() {
                        print("   - Removing older duplicate: updatedAt=\(world.updatedAt)")
                        context.delete(world)
                        worldsRemoved += 1
                        duplicateCount += 1
                    }
                    worldsKept += 1
                } else {
                    worldsKept += 1
                }
            }

            if duplicateCount > 0 {
                try context.save()
                print("✅ CloudKit merge completed: removed \(duplicateCount) duplicate(s)")
                print("   - Items: kept \(itemsKept), removed \(itemsRemoved)")
                print("   - Worlds: kept \(worldsKept), removed \(worldsRemoved)")
            } else {
                print("✅ CloudKit merge completed: no duplicates found")
                print("   - Total items: \(allItems.count)")
                print("   - Total worlds: \(allWorlds.count)")
            }
        } catch {
            print("❌ CloudKit merge failed: \(error)")
            print("   - Error details: \(error.localizedDescription)")
        }
    }
}

extension Notification.Name {
    static let modelContainerReinitializationStarted = Notification.Name("modelContainerReinitializationStarted")
    static let modelContainerReinitializationCompleted = Notification.Name("modelContainerReinitializationCompleted")
}
