# Quickstart: CoreData → SwiftData 移行

**Feature**: 002-swiftdata-migration
**Date**: 2025-12-22
**Status**: Implementation Ready

## Overview

本ドキュメントは、CoreDataからSwiftDataへの移行の開発セットアップ、実装手順、テスト方法をまとめたクイックスタートガイドです。

---

## Prerequisites

### 必要な環境

- **Xcode**: 15.0+
- **macOS**: 14.0+ (Sonoma)
- **iOS Deployment Target**: 17.0+
- **Swift**: 5.9+
- **実機**: CloudKit同期テストには2台以上のiOSデバイスが必要

### 必要な知識

- SwiftData の基礎
- CloudKit の基本概念
- MVVM アーキテクチャ
- async/await (Swift Concurrency)
- swift-dependencies の使い方
- Swift Testing の基本

---

## Setup

### 1. ブランチの作成

```bash
# 新しいフィーチャーブランチを作成
git checkout -b 002-swiftdata-migration

# または既存のブランチを使用
git checkout 002-swiftdata-migration
```

### 2. 依存関係の確認

```bash
# プロジェクトのセットアップ
make bootstrap

# SwiftDataはiOS 17+の標準ライブラリのため、追加の依存関係なし
```

### 3. プロジェクトを開く

```bash
open ios-archi.xcworkspace
```

---

## Implementation Order

実装は以下の順序で進めることを推奨します：

### Phase 1: SwiftData基盤構築（優先度：最高）

#### 1.1 SwiftDataモデル作成

1. **ItemModel.swift** を作成
   - パス: `Package/Sources/AppFeature/Data/DataSource/Local/SwiftData/Models/ItemModel.swift`
   - 内容: [data-model.md](./data-model.md) の ItemModel 定義を参照

2. **WorldModel.swift** を作成
   - パス: `Package/Sources/AppFeature/Data/DataSource/Local/SwiftData/Models/WorldModel.swift`
   - 内容: [data-model.md](./data-model.md) の WorldModel 定義を参照

3. **SwiftDataSchema.swift** を作成
   - パス: `Package/Sources/AppFeature/Data/DataSource/Local/SwiftData/SwiftDataSchema.swift`
   - スキーマバージョン管理

4. **動作確認**
   ```bash
   # ビルド確認
   xcodebuild build -workspace ios-archi.xcworkspace -scheme ios-archi
   ```

#### 1.2 SwiftDataManager実装

1. **SwiftDataManager.swift** を作成
   - パス: `Package/Sources/AppFeature/Data/DataSource/Local/SwiftData/SwiftDataManager.swift`
   - ModelContainer管理、CloudKit設定

2. **動作確認**
   ```swift
   // デバッグコードでコンテナ初期化確認
   #if DEBUG
   let manager = SwiftDataManager.shared
   print("SwiftDataManager initialized: \(manager.container)")
   #endif
   ```

#### 1.3 DataSource実装

1. **ItemsSwiftDataSource.swift** を作成
   - パス: `Package/Sources/AppFeature/Data/DataSource/Local/SwiftData/ItemsSwiftDataSource.swift`
   - CRUD操作実装

2. **WorldsSwiftDataSource.swift** を作成
   - パス: `Package/Sources/AppFeature/Data/DataSource/Local/SwiftData/WorldsSwiftDataSource.swift`
   - CRUD操作実装

3. **テストを作成**
   - `Package/Tests/AppFeatureTests/Data/SwiftData/ItemsSwiftDataSourceTests.swift`
   - `Package/Tests/AppFeatureTests/Data/SwiftData/WorldsSwiftDataSourceTests.swift`

4. **動作確認**
   ```bash
   # テスト実行
   xcodebuild test -workspace ios-archi.xcworkspace -scheme ios-archi \
     -only-testing:AppFeatureTests/ItemsSwiftDataSourceTests
   ```

---

### Phase 2: Repository層更新（優先度：高）

#### 2.1 ItemsRepository更新

1. **ItemsRepository.swift** を変更
   - パス: `Package/Sources/AppFeature/Data/Repository/ItemsRepository.swift`
   - insert/updateメソッドに画像パラメータ追加

```swift
@Mockable
protocol ItemsRepository: Sendable {
    func fetchAll() async throws -> [Item]
    func fetchWithoutNoPhoto() async throws -> [Item]
    func insert(item: Item, image: UIImage?) async throws  // 🆕 画像追加
    func update(item: Item, image: UIImage?) async throws  // 🆕 画像追加
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

    // 他のメソッドも同様に実装
}
```

2. **WorldsRepository.swift** を変更
   - SwiftDataSourceを使用するように変更

3. **テスト更新**
   - 既存のRepositoryテストを更新

#### 2.2 動作確認

```bash
# Repositoryテスト実行
xcodebuild test -workspace ios-archi.xcworkspace -scheme ios-archi \
  -only-testing:AppFeatureTests/ItemsRepositoryTests
```

---

### Phase 3: UseCase更新（優先度：中）

#### 3.1 SaveSpotImageUseCase更新

**選択肢A**: UseCaseを削除し、Repositoryに統合
**選択肢B**: データ変換の責務として残す

```swift
// 選択肢B: データ変換として残す
protocol SaveSpotImageUseCase: Sendable {
    func execute(image: UIImage) async throws -> Data?
}

struct SaveSpotImageUseCaseImpl: SaveSpotImageUseCase {
    func execute(image: UIImage) async throws -> Data? {
        return image.jpegData(compressionQuality: 0.8)
    }
}
```

#### 3.2 LoadSpotImageUseCase更新

```swift
@MainActor
struct LoadSpotImageUseCaseImpl: LoadSpotImageUseCase {
    func execute(fileName: String?) async throws -> UIImage? {
        guard let fileName else { return nil }

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

```swift
@MainActor
struct SynchronizeWithCloudUseCaseImpl: SynchronizeWithCloudUseCase {
    @Dependency(\.itemsRepository) private var itemsRepository

    func execute() async throws {
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

---

### Phase 4: 設定UI実装（優先度：中）

#### 4.1 SettingsView作成

1. **SettingsView.swift** を作成
   - パス: `Package/Sources/AppFeature/UI/Settings/SettingsView.swift`

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
                Text("iCloud同期をオンにすると、複数のデバイス間でデータが同期されます。設定変更後はアプリを再起動してください。")
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

extension Notification.Name {
    static let iCloudSyncSettingChanged = Notification.Name("iCloudSyncSettingChanged")
}
```

#### 4.2 RootViewへの統合

```swift
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

### Phase 5: UI層更新（優先度：低）

#### 5.1 ViewModel更新

**影響を受けるファイル**:
- `Package/Sources/AppFeature/UI/ItemEdit/ItemEditViewModel.swift`
- `Package/Sources/AppFeature/UI/ItemDetail/ItemDetailViewModel.swift`

**変更内容**:
```swift
// Before
try await itemsRepository.insert(item)
try await saveSpotImageUseCase.execute(image, fileName: item.id)

// After
try await itemsRepository.insert(item, image: image)
```

#### 5.2 Preview更新

```swift
#Preview {
    ItemEditView()
        .modelContainer(createPreviewContainer())
}

@MainActor
private func createPreviewContainer() -> ModelContainer {
    let schema = SwiftDataSchema.v1
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])

    // テストデータ挿入
    let context = ModelContext(container)
    let item = ItemModel.testFixture()
    context.insert(item)
    try! context.save()

    return container
}
```

---

### Phase 6: クリーンアップとテスト（優先度：低）

#### 6.1 CoreData関連削除

**削除するファイル**:
```bash
# CoreDataManager削除
rm Package/Sources/AppFeature/Data/DataSource/Local/CoreData/CoreDataManager.swift

# CoreDataモデル削除
rm -rf Package/Sources/AppFeature/Data/DataSource/Local/CoreData/Model.xcdatamodeld

# LocalDataSource削除
rm Package/Sources/AppFeature/Data/DataSource/Local/LocalDataSource.swift
rm Package/Sources/AppFeature/Data/DataSource/Local/ItemsLocalDataSource.swift
rm Package/Sources/AppFeature/Data/DataSource/Local/WorldsLocalDataSource.swift

# 画像Repository削除
rm Package/Sources/AppFeature/Data/Repository/ImageRepository/LocalImageRepository.swift
rm Package/Sources/AppFeature/Data/Repository/ImageRepository/ICloudDocumentRepository.swift
```

#### 6.2 実機テスト

**CloudKit同期確認**:
1. デバイスA: アイテムを作成（画像付き）
2. デバイスB: 同期確認（数秒〜数分待機）
3. デバイスB: アイテムと画像が表示されることを確認
4. デバイスA: アイテムを削除
5. デバイスB: 削除が同期されることを確認

**iCloud同期設定確認**:
1. 設定画面でiCloud同期をOFF
2. アプリを再起動
3. アイテムを作成
4. デバイスBで同期されないことを確認
5. 設定画面でiCloud同期をON
6. アプリを再起動
7. 新しいアイテムが同期されることを確認

#### 6.3 コード品質チェック

```bash
# SwiftLint
make lint

# SwiftFormat
make format

# ビルド確認
xcodebuild build -workspace ios-archi.xcworkspace -scheme ios-archi

# 全テスト実行
xcodebuild test -workspace ios-archi.xcworkspace -scheme ios-archi
```

#### 6.4 ドキュメント更新

1. **AGENTS.md** 更新
   - CoreData → SwiftData に更新
   - CloudKit設定の説明を更新

2. **コミット**
   ```bash
   git add .
   git commit -m "機能追加: CoreDataからSwiftDataへ移行

   - SwiftDataモデル定義（ItemModel, WorldModel）
   - SwiftDataManager実装（CloudKit同期設定）
   - DataSource実装（ItemsSwiftDataSource, WorldsSwiftDataSource）
   - Repository層更新（画像パラメータ追加）
   - 設定UI実装（iCloud同期トグル）
   - CoreData関連削除
   - Swift Testingでテスト作成

   🤖 Generated with Claude Code

   Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
   ```

---

## Usage Examples

### SwiftDataManagerの使用

```swift
// SwiftDataManagerを取得
let manager = SwiftDataManager.shared
let container = manager.container

// ModelContextを作成
let context = ModelContext(container)

// データ挿入
let item = ItemModel(id: UUID().uuidString, createdAt: Date(), updatedAt: Date())
context.insert(item)
try context.save()

// データ取得
let descriptor = FetchDescriptor<ItemModel>(
    sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
)
let items = try context.fetch(descriptor)
```

### iCloud同期設定の変更

```swift
// iCloud同期を有効化
UserDefaults.standard.set(true, forKey: "iCloudSyncEnabled")
NotificationCenter.default.post(name: .iCloudSyncSettingChanged, object: nil)

// アプリ再起動後に反映される
```

### 画像の保存と読み込み

```swift
// 保存
let imageData = image.jpegData(compressionQuality: 0.8)
let item = ItemModel(id: "test-id", spotImageData: imageData, createdAt: Date(), updatedAt: Date())
context.insert(item)
try context.save()

// 読み込み
let predicate = #Predicate<ItemModel> { $0.id == "test-id" }
let descriptor = FetchDescriptor<ItemModel>(predicate: predicate)
let items = try context.fetch(descriptor)
let image = items.first?.spotImageData.flatMap { UIImage(data: $0) }
```

---

## Testing

### テストの実行

```bash
# 全テスト実行
xcodebuild test -workspace ios-archi.xcworkspace -scheme ios-archi

# SwiftDataSourceテストのみ
xcodebuild test -workspace ios-archi.xcworkspace -scheme ios-archi \
  -only-testing:AppFeatureTests/ItemsSwiftDataSourceTests

# 特定のテストケース
xcodebuild test -workspace ios-archi.xcworkspace -scheme ios-archi \
  -only-testing:AppFeatureTests/ItemsSwiftDataSourceTests/testInsertAndFetch
```

### テストの記述例（Swift Testing）

```swift
import Testing
import SwiftData
@testable import AppFeature

@Suite("ItemsSwiftDataSource Tests")
struct ItemsSwiftDataSourceTests {

    @MainActor
    @Test("アイテムを保存して取得できる")
    func testInsertAndFetch() async throws {
        let container = try createTestContainer()
        let sut = ItemsSwiftDataSourceImpl(container: container)

        let item = Item(
            id: UUID().uuidString,
            coordinates: Coordinates(x: 100, y: 64, z: 200),
            world: nil,
            spotImageName: nil,
            createdAt: Date(),
            updatedAt: Date()
        )

        try await sut.insert(item, imageData: nil)
        let items = try await sut.fetchAll()

        #expect(items.count == 1)
        #expect(items.first?.id == item.id)
    }
}

@MainActor
private func createTestContainer() throws -> ModelContainer {
    let schema = SwiftDataSchema.v1
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    return try ModelContainer(for: schema, configurations: [config])
}
```

---

## Debugging

### SwiftDataManagerの状態確認

```swift
#if DEBUG
let manager = SwiftDataManager.shared
print("iCloud同期: \(UserDefaults.standard.bool(forKey: "iCloudSyncEnabled"))")
print("Container: \(manager.container)")
#endif
```

### CloudKit同期状況の確認

```bash
# CloudKitダッシュボードで確認
# https://icloud.developer.apple.com/dashboard

# デバイスでデータベース確認
# 設定 > Apple ID > iCloud > iCloudストレージを管理 > アプリ名
```

### UserDefaultsの確認

```swift
// LLDBで確認
(lldb) po UserDefaults.standard.dictionaryRepresentation()

// コードで確認
print("iCloudSyncEnabled: \(UserDefaults.standard.bool(forKey: "iCloudSyncEnabled"))")
```

---

## Troubleshooting

### 問題: CloudKit同期が動作しない

**原因**: iCloudアカウントにサインインしていない、またはEntitlementsが正しく設定されていない

**解決策**:
1. デバイスでiCloudにサインインしているか確認
2. Entitlementsに `com.apple.developer.icloud-container-identifiers` が設定されているか確認
3. CloudKitダッシュボードでコンテナが作成されているか確認

### 問題: 設定変更が反映されない

**原因**: アプリを再起動していない

**解決策**: 設定変更後、アプリを完全に終了して再起動

### 問題: ビルドエラー "Sendable protocol requirement not satisfied"

**原因**: SwiftDataモデルがSendable準拠していない

**解決策**:
```swift
@Model
final class ItemModel {  // finalキーワードが必要
    // ...
}
```

---

## Performance Optimization

### クエリ最適化

```swift
// fetchLimitで大量データを制限
let descriptor = FetchDescriptor<ItemModel>(
    sortBy: [SortDescriptor(\.createdAt, order: .reverse)],
    fetchLimit: 100
)
```

### メモリ管理

SwiftDataはFault機構により自動的にメモリ管理を行いますが、大量データを扱う場合は注意：

```swift
// 大量データ処理時は小分けにフェッチ
for offset in stride(from: 0, to: totalCount, by: 100) {
    var descriptor = FetchDescriptor<ItemModel>(
        sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
    )
    descriptor.fetchLimit = 100
    descriptor.fetchOffset = offset

    let items = try context.fetch(descriptor)
    // 処理
}
```

---

## Next Steps

実装完了後：

1. **実機テスト**: 複数のiOSデバイスでCloudKit同期を確認
2. **パフォーマンステスト**: Instrumentsでメモリリーク、パフォーマンスを確認
3. **プルリクエスト作成**: GitHub Issuesと連携
4. **App Store申請準備**: データリセットの説明文を追加

---

## References

- [Feature Specification](./spec.md)
- [Implementation Plan](./plan.md)
- [Research Document](./research.md)
- [Data Model](./data-model.md)
- [SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)
- [CloudKit Documentation](https://developer.apple.com/documentation/cloudkit)

---

**Happy Coding!** 🚀
