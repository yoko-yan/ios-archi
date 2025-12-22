# CoreData → SwiftData 移行実装計画

## 概要

現在のCoreData + CloudKit実装をSwiftDataベースに移行し、将来的なFirebase同期拡張も可能な設計を行います。

### 要件
- ✅ 既存データは破棄（新規インストール扱い）
- ✅ iCloud同期を設定画面でオン/オフ切り替え可能
- ✅ Firebaseは将来拡張のためアーキテクチャのみ考慮
- ✅ 画像はSwiftData ExternalStorageで管理

## アーキテクチャ概要

```
┌─────────────────────────────────────┐
│ UI Layer (SwiftUI Views)            │
├─────────────────────────────────────┤
│ Domain Layer (UseCases)             │
├─────────────────────────────────────┤
│ Data Layer                          │
│  ├─ Repository (抽象化)             │
│  ├─ DataSource (SwiftData実装)      │
│  └─ SwiftDataManager (Container管理)│
├─────────────────────────────────────┤
│ SwiftData + CloudKit同期            │
└─────────────────────────────────────┘
```

## 実装フェーズ

### Phase 1: SwiftData基盤構築 🔴 最優先

#### 1.1 SwiftDataモデル作成

**新規ファイル**: `/Package/Sources/AppFeature/Data/DataSource/Local/SwiftData/Models/ItemModel.swift`
```swift
@Model
final class ItemModel {
    @Attribute(.unique) var id: String
    var coordinatesX: String?
    var coordinatesY: String?
    var coordinatesZ: String?
    var worldID: String?
    var name: String?
    var comment: String?

    // 画像をExternalStorageに保存
    @Attribute(.externalStorage) var spotImageData: Data?

    var createdAt: Date
    var updatedAt: Date
}
```

**新規ファイル**: `/Package/Sources/AppFeature/Data/DataSource/Local/SwiftData/Models/WorldModel.swift`
```swift
@Model
final class WorldModel {
    @Attribute(.unique) var id: String
    var name: String?
    var seed: String?  // Seed.rawValueを文字列保存
    var comment: String?
    var createdAt: Date
    var updatedAt: Date
}
```

**新規ファイル**: `/Package/Sources/AppFeature/Data/DataSource/Local/SwiftData/SwiftDataSchema.swift`
```swift
enum SwiftDataSchema {
    static let v1 = Schema([ItemModel.self, WorldModel.self])
}
```

**検証**: モデルの初期化テストをQuick/Nimbleで作成

#### 1.2 SwiftDataManager実装

**新規ファイル**: `/Package/Sources/AppFeature/Data/DataSource/Local/SwiftData/SwiftDataManager.swift`

```swift
@MainActor
final class SwiftDataManager {
    static let shared = SwiftDataManager()
    private(set) var container: ModelContainer!

    private var iCloudSyncEnabled: Bool {
        UserDefaults.standard.bool(forKey: "iCloudSyncEnabled")
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
        let schema = SwiftDataSchema.v1
        let config: ModelConfiguration

        if iCloudSyncEnabled {
            config = ModelConfiguration(
                schema: schema,
                cloudKitDatabase: .automatic
            )
        } else {
            config = ModelConfiguration(
                schema: schema,
                cloudKitDatabase: .none
            )
        }

        container = try! ModelContainer(for: schema, configurations: [config])
    }

    @objc private func handleSyncSettingChanged() {
        // 注意: 設定変更後はアプリ再起動が必要
        setupContainer()
    }
}

extension Notification.Name {
    static let iCloudSyncSettingChanged = Notification.Name("iCloudSyncSettingChanged")
}
```

**重要**: ModelConfigurationは初期化時に設定するため、動的切り替えには**アプリ再起動が必要**です。

#### 1.3 DataSource実装

**新規ファイル**: `/Package/Sources/AppFeature/Data/DataSource/Local/SwiftData/ItemsSwiftDataSource.swift`

```swift
protocol ItemsSwiftDataSource: Sendable {
    func fetchAll() async throws -> [Item]
    func fetchWithoutNoPhoto() async throws -> [Item]
    func insert(_ item: Item, imageData: Data?) async throws
    func update(_ item: Item, imageData: Data?) async throws
    func delete(_ item: Item) async throws
}

@MainActor
final class ItemsSwiftDataSourceImpl: ItemsSwiftDataSource {
    private let container: ModelContainer
    private let worldsDataSource: any WorldsSwiftDataSource

    init(
        container: ModelContainer = SwiftDataManager.shared.container,
        worldsDataSource: some WorldsSwiftDataSource = WorldsSwiftDataSourceImpl()
    ) {
        self.container = container
        self.worldsDataSource = worldsDataSource
    }

    func fetchAll() async throws -> [Item] {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<ItemModel>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        let models = try context.fetch(descriptor)
        return try await models.asyncMap { try await convertToDomain($0) }
    }

    func fetchWithoutNoPhoto() async throws -> [Item] {
        let context = ModelContext(container)
        let predicate = #Predicate<ItemModel> { $0.spotImageData != nil }
        let descriptor = FetchDescriptor<ItemModel>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        let models = try context.fetch(descriptor)
        return try await models.asyncMap { try await convertToDomain($0) }
    }

    func insert(_ item: Item, imageData: Data?) async throws {
        let context = ModelContext(container)
        let model = ItemModel(
            id: item.id,
            coordinatesX: item.coordinates?.x.description,
            coordinatesY: item.coordinates?.y.description,
            coordinatesZ: item.coordinates?.z.description,
            worldID: item.world?.id,
            spotImageData: imageData,
            createdAt: item.createdAt,
            updatedAt: Date()
        )
        context.insert(model)
        try context.save()
    }

    // update, delete, convertToDomain実装省略（同様のパターン）
}
```

**新規ファイル**: `/Package/Sources/AppFeature/Data/DataSource/Local/SwiftData/WorldsSwiftDataSource.swift`
- 同様のパターンで実装

**検証**: 各CRUD操作の単体テストを作成

---

### Phase 2: Repository層更新 🔴 最優先

#### 2.1 ItemsRepository更新

**変更ファイル**: `/Package/Sources/AppFeature/Data/Repository/ItemsRepository.swift`

```swift
@Mockable
protocol ItemsRepository: Sendable {
    func fetchAll() async throws -> [Item]
    func fetchWithoutNoPhoto() async throws -> [Item]
    func insert(item: Item, image: UIImage?) async throws  // 🆕 画像パラメータ追加
    func update(item: Item, image: UIImage?) async throws  // 🆕 画像パラメータ追加
    func delete(item: Item) async throws
}

struct ItemsRepositoryImpl: ItemsRepository {
    private let dataSource: any ItemsSwiftDataSource

    init(dataSource: some ItemsSwiftDataSource = ItemsSwiftDataSourceImpl()) {
        self.dataSource = dataSource
    }

    func insert(item: Item, image: UIImage?) async throws {
        let imageData = image?.jpegData(compressionQuality: 0.8)
        try await dataSource.insert(item, imageData: imageData)
    }

    func update(item: Item, image: UIImage?) async throws {
        let imageData = image?.jpegData(compressionQuality: 0.8)
        try await dataSource.update(item, imageData: imageData)
    }

    // 他のメソッドは既存実装を流用
}
```

#### 2.2 WorldsRepository更新

**変更ファイル**: `/Package/Sources/AppFeature/Data/Repository/WorldsRepository.swift`
- SwiftDataSourceを使用するように変更
- DependencyValues対応を追加（現在は未対応）

**検証**: Repository Mock作成、既存テスト更新

---

### Phase 3: UseCase更新 🟡 中優先度

#### 3.1 画像保存UseCase統合

**変更ファイル**: `/Package/Sources/AppFeature/Domain/SaveSpotImageUseCase.swift`

```swift
// 🗑️ このUseCaseは不要になる可能性あり
// ItemsRepositoryが画像を直接扱うようになるため

// または、データ変換の責務として残す場合：
protocol SaveSpotImageUseCase: Sendable {
    func execute(image: UIImage) async throws -> Data?
}

struct SaveSpotImageUseCaseImpl: SaveSpotImageUseCase {
    func execute(image: UIImage) async throws -> Data? {
        // 圧縮してDataとして返す
        return image.jpegData(compressionQuality: 0.8)
    }
}
```

#### 3.2 画像読み込みUseCase更新

**変更ファイル**: `/Package/Sources/AppFeature/Domain/LoadSpotImageUseCase.swift`

```swift
@MainActor
struct LoadSpotImageUseCaseImpl: LoadSpotImageUseCase {
    func execute(fileName: String?) async throws -> UIImage? {
        guard let fileName else { return nil }

        // SwiftDataから画像データ取得
        let container = SwiftDataManager.shared.container
        let context = ModelContext(container)

        let predicate = #Predicate<ItemModel> { $0.id == fileName }
        let descriptor = FetchDescriptor<ItemModel>(predicate: predicate)

        guard let model = try context.fetch(descriptor).first,
              let imageData = model.spotImageData else {
            return nil
        }

        return UIImage(data: imageData)
    }
}
```

#### 3.3 SynchronizeWithCloudUseCase更新

**変更ファイル**: `/Package/Sources/AppFeature/Domain/SynchronizeWithCloudUseCase.swift`

```swift
@MainActor
struct SynchronizeWithCloudUseCaseImpl: SynchronizeWithCloudUseCase {
    @Dependency(\.itemsRepository) private var itemsRepository

    func execute() async throws {
        // iCloud同期が無効な場合はスキップ
        guard UserDefaults.standard.bool(forKey: "iCloudSyncEnabled") else {
            return
        }

        // 初回フェッチでCloudKit同期をトリガー
        _ = try await itemsRepository.fetchAll()

        // SwiftDataは自動同期のため、短い待機時間で十分
        try await Task.sleep(for: .seconds(3))
    }
}
```

**注意**: SwiftDataはNSPersistentCloudKitContainerのような明示的な同期イベント通知がないため、シンプルな待機処理になります。

---

### Phase 4: 設定UI実装 🟡 中優先度

#### 4.1 設定画面作成

**新規ファイル**: `/Package/Sources/AppFeature/UI/Settings/SettingsView.swift`

```swift
import SwiftUI

struct SettingsView: View {
    @AppStorage("iCloudSyncEnabled") private var iCloudSyncEnabled = true
    @State private var showRestartAlert = false

    var body: some View {
        Form {
            Section {
                Toggle("iCloud同期", isOn: $iCloudSyncEnabled)
                    .onChange(of: iCloudSyncEnabled) { _, _ in
                        handleSyncToggle()
                    }
            } header: {
                Text("データ同期")
            } footer: {
                Text("iCloud同期をオンにすると、複数のデバイス間でデータが同期されます。")
            }

            if showRestartAlert {
                Section {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.orange)
                        Text("設定を反映するにはアプリを再起動してください")
                            .font(.caption)
                    }
                }
            }
        }
        .navigationTitle("設定")
    }

    private func handleSyncToggle() {
        NotificationCenter.default.post(name: .iCloudSyncSettingChanged, object: nil)
        showRestartAlert = true
    }
}
```

#### 4.2 RootViewへの統合

**変更ファイル**: `/Package/Sources/AppFeature/UI/RootView/RootView.swift`

```swift
// TabViewまたはNavigationStackに設定画面を追加
// 既存の画面構成を確認してから統合

@MainActor
public struct RootView: View {
    @State private var viewModel = RootViewModel()

    public var body: some View {
        Group {
            if viewModel.uiState.isLaunching {
                SplashView()
            } else {
                TabView {
                    // 既存のタブ...

                    NavigationStack {
                        SettingsView()
                    }
                    .tabItem {
                        Label("設定", systemImage: "gear")
                    }
                }
            }
        }
        .task {
            await viewModel.load()
        }
        .modelContainer(SwiftDataManager.shared.container)  // 🆕 SwiftData注入
    }
}
```

---

### Phase 5: UI層更新 🟢 低優先度

#### 5.1 ViewModel更新

**影響を受けるファイル**:
- `/Package/Sources/AppFeature/UI/ItemEdit/ItemEditViewModel.swift`
- `/Package/Sources/AppFeature/UI/ItemDetail/ItemDetailViewModel.swift`
- 他、Itemを扱うViewModel

**変更内容**:
- `itemsRepository.insert(item, image: image)` のように画像を渡す
- `itemsRepository.update(item, image: image)` のように画像を渡す
- 既存の`SaveSpotImageUseCase`呼び出しを削除

#### 5.2 Preview更新

- SwiftDataのModelContainerをPreview環境で使用
- インメモリコンテナでテストデータ作成

---

### Phase 6: クリーンアップ 🟢 低優先度

#### 6.1 CoreData関連削除

**削除するファイル**:
- `/Package/Sources/AppFeature/Data/DataSource/Local/CoreData/CoreDataManager.swift`
- `/Package/Sources/AppFeature/Data/DataSource/Local/CoreData/Model.xcdatamodeld`
- `/Package/Sources/AppFeature/Data/DataSource/Local/ItemsLocalDataSource.swift`
- `/Package/Sources/AppFeature/Data/DataSource/Local/WorldsLocalDataSource.swift`
- `/Package/Sources/AppFeature/Data/DataSource/Local/LocalDataSource.swift`

**削除するファイル（画像関連）**:
- `/Package/Sources/AppFeature/Data/Repository/ImageRepository/LocalImageRepository.swift`
- `/Package/Sources/AppFeature/Data/Repository/ImageRepository/ICloudDocumentRepository.swift`

**注意**: バックアップを取ってから削除（Gitでコミット前に確認）

#### 6.2 ドキュメント更新

**変更ファイル**: `/Users/apla/workspace/projects/source/ios-archi/CLAUDE.md`
- CoreData → SwiftData へ更新
- CloudKit設定の説明を更新
- 新しい設定画面の説明を追加

---

## 将来のFirebase拡張を考慮した設計（今回は未実装）

### 抽象化レイヤー（将来実装）

**将来作成**: `/Package/Sources/AppFeature/Data/Sync/SyncProtocol.swift`

```swift
enum SyncProvider {
    case cloudKit
    case firebase
    case local
}

protocol SyncManager: Sendable {
    var provider: SyncProvider { get }
    func synchronize() async throws
    func enableSync(_ enabled: Bool) async throws
}

// CloudKit実装
struct CloudKitSyncManager: SyncManager {
    let provider: SyncProvider = .cloudKit
    func synchronize() async throws { /* SwiftData同期待機 */ }
    func enableSync(_ enabled: Bool) async throws { /* UserDefaults更新 */ }
}

// Firebase実装（将来）
struct FirebaseSyncManager: SyncManager {
    let provider: SyncProvider = .firebase
    func synchronize() async throws { /* Firestore同期 */ }
    func enableSync(_ enabled: Bool) async throws { /* Firebase設定 */ }
}
```

**将来の設定UI拡張**:
```swift
Picker("同期プロバイダー", selection: $syncProvider) {
    Text("iCloud").tag("cloudKit")
    Text("Firebase").tag("firebase")
    Text("同期なし").tag("local")
}
```

---

## 重要な注意点

### SwiftData制約
- ⚠️ **@MainActor必須**: ModelContextはメインスレッドでのみ動作
- ⚠️ **Predicate制約**: 複雑なクエリはコンパイルエラーになる場合あり
- ⚠️ **リレーションシップ**: CloudKit同期時に不安定な場合あり → 文字列ID参照を推奨

### CloudKit同期の制約
- ⚠️ **初回同期時間**: データ量に応じて数秒〜数分かかる
- ⚠️ **競合解決**: Last Write Wins（最終書き込み優先）
- ⚠️ **動的切り替え**: ModelConfigurationは初期化時設定のため、設定変更後は**アプリ再起動が必要**

### 移行時の注意
- 🚨 **既存データ**: 新規インストール扱いのため、ユーザーに事前通知が必要
- 🚨 **画像ファイル**: DocumentDirectory内の既存画像は手動移行が必要な場合あり
- 🚨 **バージョンアップ**: App Store説明文に「データがリセットされる」旨を記載

---

## 実装順序（推奨）

1. **Phase 1.1-1.3**: SwiftData基盤構築（モデル、Manager、DataSource）
2. **Phase 2**: Repository層更新
3. **Phase 3**: UseCase更新
4. **Phase 1.3 テスト**: DataSourceの単体テスト作成・実行
5. **Phase 4**: 設定UI実装
6. **Phase 5**: UI層更新（ViewModel、View）
7. **実機テスト**: CloudKit同期動作確認（2台のデバイス）
8. **Phase 6**: CoreData関連削除、ドキュメント更新

---

## テスト戦略

### 単体テスト（Quick/Nimble）

```swift
@MainActor
final class ItemsSwiftDataSourceSpec: AsyncSpec {
    override class func spec() {
        describe("ItemsSwiftDataSource") {
            var sut: ItemsSwiftDataSourceImpl!
            var container: ModelContainer!

            beforeEach {
                let schema = SwiftDataSchema.v1
                let config = ModelConfiguration(
                    schema: schema,
                    isStoredInMemoryOnly: true  // インメモリテスト
                )
                container = try! ModelContainer(for: schema, configurations: [config])
                sut = ItemsSwiftDataSourceImpl(container: container)
            }

            context("insert") {
                it("should save item successfully") {
                    let item = Item(id: UUID().uuidString, ...)
                    await expect {
                        try await sut.insert(item, imageData: nil)
                    }.toNot(throwError())
                }
            }
        }
    }
}
```

### 実機検証チェックリスト

**CloudKit同期**:
- [ ] デバイスA: アイテム作成 → デバイスB: 同期確認
- [ ] デバイスA: 画像付きアイテム作成 → デバイスB: 画像表示確認
- [ ] 設定でiCloud同期OFF → アプリ再起動 → 同期停止確認
- [ ] 設定でiCloud同期ON → アプリ再起動 → 同期再開確認

**画像ExternalStorage**:
- [ ] 大きな画像（5MB以上）保存 → 正常保存確認
- [ ] アイテム削除 → 画像も削除されることを確認

---

## Critical Files

### 新規作成ファイル
- `/Package/Sources/AppFeature/Data/DataSource/Local/SwiftData/Models/ItemModel.swift`
- `/Package/Sources/AppFeature/Data/DataSource/Local/SwiftData/Models/WorldModel.swift`
- `/Package/Sources/AppFeature/Data/DataSource/Local/SwiftData/SwiftDataSchema.swift`
- `/Package/Sources/AppFeature/Data/DataSource/Local/SwiftData/SwiftDataManager.swift`
- `/Package/Sources/AppFeature/Data/DataSource/Local/SwiftData/ItemsSwiftDataSource.swift`
- `/Package/Sources/AppFeature/Data/DataSource/Local/SwiftData/WorldsSwiftDataSource.swift`
- `/Package/Sources/AppFeature/UI/Settings/SettingsView.swift`

### 変更ファイル
- `/Package/Sources/AppFeature/Data/Repository/ItemsRepository.swift`
- `/Package/Sources/AppFeature/Data/Repository/WorldsRepository.swift`
- `/Package/Sources/AppFeature/Domain/SaveSpotImageUseCase.swift`
- `/Package/Sources/AppFeature/Domain/LoadSpotImageUseCase.swift`
- `/Package/Sources/AppFeature/Domain/SynchronizeWithCloudUseCase.swift`
- `/Package/Sources/AppFeature/UI/RootView/RootView.swift`
- `/Users/apla/workspace/projects/source/ios-archi/CLAUDE.md`

### 削除ファイル（Phase 6）
- CoreData関連すべて
- ImageRepository関連（LocalImageRepository, ICloudDocumentRepository）
