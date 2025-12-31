# Research: CoreData → SwiftData 移行

**Feature**: 002-swiftdata-migration
**Date**: 2025-12-22
**Status**: Complete

## Overview

本文書は、CoreDataからSwiftDataへの移行に関する技術調査結果をまとめたものです。現在のNSPersistentCloudKitContainerベースの実装を、SwiftDataとModelConfigurationベースに移行し、将来的なFirebase同期拡張も可能な設計を実現します。

---

## Research Topics

### 1. SwiftData vs CoreData

#### Decision

SwiftDataを採用し、CoreDataから完全移行する。

**SwiftData の主な利点**:
- **宣言的モデル定義**: `@Model`マクロで自動的にプロパティが永続化対象に
- **型安全なクエリ**: `#Predicate`マクロでコンパイル時に型チェック
- **Swift Concurrency統合**: async/awaitとの統合が深い
- **簡潔なAPI**: CoreDataのNSManagedObjectContextに比べてシンプル
- **CloudKit同期**: ModelConfigurationで簡単に設定可能

**実装パターン**:
```swift
@Model
final class ItemModel {
    @Attribute(.unique) var id: String
    @Attribute(.externalStorage) var spotImageData: Data?
    var coordinatesX: String?
    var createdAt: Date
    var updatedAt: Date
}

// クエリ
let context = ModelContext(container)
let predicate = #Predicate<ItemModel> { $0.spotImageData != nil }
let descriptor = FetchDescriptor<ItemModel>(
    predicate: predicate,
    sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
)
let items = try context.fetch(descriptor)
```

#### Rationale

**CoreDataの課題**:
- NSManagedObjectContext の複雑な管理（viewContext, backgroundContext）
- NSFetchRequest の冗長な記述
- スレッド安全性の手動管理（perform block）
- CloudKit同期時のマージ処理の複雑さ

**SwiftDataの優位性**:
- モデル定義が簡潔（`@Model`マクロ）
- 型安全なクエリ（`#Predicate`マクロ）
- Swift Concurrencyとの統合（async/await）
- iOS 17+のみサポートのため、最新機能を活用可能

#### Alternatives Considered

1. **CoreData継続**: 既存実装を維持できるが、学習プロジェクトとして新技術習得の機会を逃す
2. **Realm**: サードパーティライブラリで依存関係が増える。CloudKit同期が公式サポートでない

#### References

- [Apple Developer: SwiftData](https://developer.apple.com/documentation/swiftdata)
- [WWDC 2023: Meet SwiftData](https://developer.apple.com/videos/play/wwdc2023/10187/)
- [SwiftData Migration Guide](https://developer.apple.com/documentation/swiftdata/migrating-from-core-data-to-swiftdata)

---

### 2. 画像保存方法：ExternalStorage vs ファイルシステム

#### Decision

SwiftDataの`@Attribute(.externalStorage)`を使用して画像を管理する。

**実装パターン**:
```swift
@Model
final class ItemModel {
    @Attribute(.unique) var id: String

    // 画像をSwiftDataのExternalStorageに保存
    @Attribute(.externalStorage) var spotImageData: Data?

    var createdAt: Date
}

// 保存
let imageData = image.jpegData(compressionQuality: 0.8)
let item = ItemModel(id: UUID().uuidString, spotImageData: imageData, createdAt: Date())
context.insert(item)
try context.save()

// 読み込み
let image = UIImage(data: item.spotImageData!)
```

#### Rationale

**ExternalStorage の利点**:
- **自動管理**: SwiftDataが自動的に大きなデータを外部ストレージに保存
- **CloudKit同期**: ExternalStorageのデータも自動的にCloudKitで同期
- **メモリ効率**: 必要な時だけメモリにロードされる（fault機構）
- **削除の自動化**: エンティティ削除時に画像も自動削除

**従来のファイルシステム保存の課題**:
- ファイルパスの手動管理が必要
- CloudKit同期時に画像を別途アップロード/ダウンロード処理が必要
- エンティティ削除時にファイルの手動削除が必要
- 孤立ファイルのリスク

#### Alternatives Considered

1. **DocumentDirectoryに保存**: 既存実装と同じだが、CloudKit同期が煩雑
2. **UIDocumentベースのiCloud Documents**: UIDocument + NSFileCoordinatorでの実装が複雑
3. **CoreDataのbinaryData + allowsExternalBinaryDataStorage**: CoreDataを継続使用する場合のみ有効

#### Performance Considerations

- **データサイズ**: 通常のスクリーンショット画像は1-3MB程度
- **ExternalStorageの閾値**: SwiftDataが自動的に閾値を判断（通常1MB程度）
- **メモリ使用**: Fault機構により、必要な画像のみメモリにロード

#### References

- [Apple Developer: ExternalStorage Attribute](https://developer.apple.com/documentation/swiftdata/schema/attribute/option/externalStorage)

---

### 3. CloudKit同期設定：ModelConfiguration

#### Decision

ModelConfigurationの`cloudKitDatabase`パラメータでCloudKit同期を制御する。

**実装パターン**:
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
    }

    private func setupContainer() {
        let schema = SwiftDataSchema.v1
        let config: ModelConfiguration

        if iCloudSyncEnabled {
            // CloudKit同期有効
            config = ModelConfiguration(
                schema: schema,
                cloudKitDatabase: .automatic  // または .private
            )
        } else {
            // ローカルのみ
            config = ModelConfiguration(
                schema: schema,
                cloudKitDatabase: .none
            )
        }

        container = try! ModelContainer(for: schema, configurations: [config])
    }
}
```

#### Rationale

**ModelConfigurationの利点**:
- **簡潔な設定**: 1行で CloudKit 同期を有効化
- **自動マージ**: SwiftDataが自動的に競合解決
- **トランザクション管理**: 同期処理を内部で最適化

**cloudKitDatabase オプション**:
- `.automatic`: プライベートデータベースとパブリックデータベースの両方を使用
- `.private`: プライベートデータベースのみ（個人データ向け）
- `.none`: CloudKit同期なし（ローカルのみ）

#### Limitations

**動的切り替えの制約**:
- ModelConfigurationは初期化時に設定
- 実行中の動的切り替えは困難
- **解決策**: 設定変更後にアプリ再起動を促す、または2つのコンテナを用意

**代替案（複数コンテナ）**:
```swift
private var localContainer: ModelContainer!
private var cloudContainer: ModelContainer!

var activeContainer: ModelContainer {
    iCloudSyncEnabled ? cloudContainer : localContainer
}
```

この場合、コンテナ間のデータマイグレーションが必要になり複雑化するため、**アプリ再起動を推奨**します。

#### Alternatives Considered

1. **NSPersistentCloudKitContainerの継続使用**: CoreDataを継続する場合のみ有効
2. **手動CloudKit同期**: CKRecordを手動管理するが、SwiftDataの自動同期より煩雑

#### References

- [Apple Developer: ModelConfiguration](https://developer.apple.com/documentation/swiftdata/modelconfiguration)
- [WWDC 2023: Build an app with SwiftData](https://developer.apple.com/videos/play/wwdc2023/10154/)

---

### 4. 設定UI：iCloud同期のオン/オフ切り替え

#### Decision

SwiftUIの`@AppStorage`とUserDefaultsでiCloud同期設定を管理し、設定画面でトグル切り替えを提供する。

**実装パターン**:
```swift
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

#### Rationale

**UserDefaults選択理由**:
- 設定データは小さい（Bool値1つ）
- @AppStorageとの統合が容易
- アプリ起動時に即座に読み込み可能

**再起動の必要性**:
- ModelConfigurationは初期化時に設定
- 実行中の変更は複雑（コンテナ再構築、データマイグレーション）
- **ユーザー体験**: 再起動を明示的に促すことで、設定変更の影響を理解しやすい

#### Alternatives Considered

1. **動的切り替え（複数コンテナ）**: 実装が複雑で、データマイグレーションのリスクが高い
2. **アプリ自動再起動**: `exit(0)`で強制終了するのはApp Store審査で却下される可能性
3. **設定変更時にコンテナ再構築**: データロスのリスクがある

#### User Experience Considerations

- **明確なフィードバック**: 設定変更後に再起動が必要であることを明示
- **再起動手順の説明**: 必要に応じて、アプリの再起動方法を説明
- **デフォルト値**: iCloud同期はデフォルトでON（多くのユーザーが期待する動作）

#### References

- [Apple Developer: AppStorage](https://developer.apple.com/documentation/swiftui/appstorage)
- [Human Interface Guidelines: Settings](https://developer.apple.com/design/human-interface-guidelines/settings)

---

### 5. データマイグレーション戦略

#### Decision

**新規インストール扱い**：既存のCoreDataからSwiftDataへの自動マイグレーションは行わない。

**根拠**:
- 学習プロジェクトであり、本番データの保護が最優先ではない
- CoreData → SwiftData の自動マイグレーションは複雑で、エラーのリスクが高い
- ユーザー数が少ない段階での移行であれば、影響が限定的

**ユーザーへの通知**:
- App Store アップデート説明文に「データがリセットされる」旨を記載
- アプリ起動時に警告ダイアログを表示（初回のみ）

**将来的なマイグレーション（必要な場合）**:
```swift
// CoreDataからSwiftDataへの手動マイグレーション
func migrateCoreDataToSwiftData() async throws {
    let coreDataContext = CoreDataManager.shared.viewContext
    let swiftDataContext = ModelContext(SwiftDataManager.shared.container)

    // CoreDataから全データ取得
    let coreDataItems = try coreDataContext.fetch(ItemEntity.fetchRequest())

    // SwiftDataに変換して挿入
    for coreDataItem in coreDataItems {
        let swiftDataItem = ItemModel(
            id: coreDataItem.id?.uuidString ?? UUID().uuidString,
            coordinatesX: coreDataItem.coordinatesX,
            // ... 他のフィールドをマッピング
            createdAt: coreDataItem.createdAt ?? Date()
        )
        swiftDataContext.insert(swiftDataItem)
    }

    try swiftDataContext.save()
}
```

#### Alternatives Considered

1. **自動マイグレーション**: 実装が複雑で、テストが困難
2. **並行運用**: CoreDataとSwiftDataを同時に使用するが、データ同期が煩雑

#### References

- [Apple Developer: Migrating from Core Data](https://developer.apple.com/documentation/swiftdata/migrating-from-core-data-to-swiftdata)

---

### 6. 将来のFirebase拡張を考慮した設計

#### Decision

SyncManagerプロトコルで同期処理を抽象化し、CloudKitとFirebaseを切り替え可能にする。

**アーキテクチャ**:
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

    func synchronize() async throws {
        // SwiftDataのCloudKit同期待機
        // ModelConfigurationで自動同期されるため、待機のみ
        try await Task.sleep(for: .seconds(3))
    }

    func enableSync(_ enabled: Bool) async throws {
        UserDefaults.standard.set(enabled, forKey: "iCloudSyncEnabled")
        NotificationCenter.default.post(name: .iCloudSyncSettingChanged, object: nil)
    }
}

// Firebase実装（将来）
struct FirebaseSyncManager: SyncManager {
    let provider: SyncProvider = .firebase

    func synchronize() async throws {
        // Firestore同期処理
        // 1. ローカルのSwiftDataから変更を取得
        // 2. Firestoreにアップロード
        // 3. Firestoreから変更をダウンロード
        // 4. SwiftDataに反映
    }

    func enableSync(_ enabled: Bool) async throws {
        UserDefaults.standard.set(enabled, forKey: "firebaseSyncEnabled")
    }
}
```

**Repository層での使用**:
```swift
struct ItemsRepositoryImpl: ItemsRepository {
    private let localDataSource: any ItemsSwiftDataSource
    private let syncManager: any SyncManager

    init(
        localDataSource: some ItemsSwiftDataSource = ItemsSwiftDataSourceImpl(),
        syncManager: some SyncManager = CloudKitSyncManager()  // 設定で切り替え可能
    ) {
        self.localDataSource = localDataSource
        self.syncManager = syncManager
    }

    func fetchAll() async throws -> [Item] {
        // 同期実行
        try await syncManager.synchronize()

        // ローカルから取得
        return try await localDataSource.fetchAll()
    }
}
```

#### Rationale

**抽象化の利点**:
- **プロバイダー切り替え**: CloudKit ↔ Firebase の切り替えが容易
- **テスト容易性**: SyncManager のモックが作成可能
- **段階的実装**: CloudKitを先に実装し、Firebaseは後から追加可能

**Firebase同期の課題**:
- SwiftDataはFirebaseネイティブサポートなし
- 手動でFirestore ↔ SwiftData の同期処理が必要
- 競合解決のロジックを自前で実装

#### Implementation Strategy

**Phase 1（今回）**: CloudKitのみ実装
**Phase 2（将来）**: SyncProtocol抽象化レイヤー追加
**Phase 3（将来）**: FirebaseSyncManager実装

#### Alternatives Considered

1. **直接Firebase SDKを使用**: SyncProtocolなしで直接実装するが、切り替えが困難
2. **マルチプラットフォームDB（Realm）**: サードパーティ依存が増える

#### References

- [Firebase iOS SDK](https://firebase.google.com/docs/ios/setup)
- [Firestore Documentation](https://firebase.google.com/docs/firestore)

---

### 7. テストフレームワーク：Swift Testing vs Quick/Nimble

#### Decision

**憲章に従い、Swift Testingを使用する。**

ただし、既存のプロジェクトにはQuick/Nimbleを使用したテストが存在する可能性があるため、**新規テストはSwift Testing、既存テストは段階的に移行**とします。

**実装パターン**:
```swift
import Testing
import SwiftData
@testable import AppFeature

@Suite("ItemsSwiftDataSource Tests")
struct ItemsSwiftDataSourceTests {

    @MainActor
    @Test("アイテムを保存して取得できる")
    func testInsertAndFetch() async throws {
        // インメモリコンテナでテスト
        let schema = SwiftDataSchema.v1
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )
        let container = try ModelContainer(for: schema, configurations: [config])
        let sut = ItemsSwiftDataSourceImpl(container: container)

        // アイテム作成
        let item = Item(
            id: UUID().uuidString,
            coordinates: Coordinates(x: 100, y: 64, z: 200),
            world: nil,
            spotImageName: nil,
            createdAt: Date(),
            updatedAt: Date()
        )

        // 保存
        try await sut.insert(item, imageData: nil)

        // 取得
        let items = try await sut.fetchAll()

        // 検証
        #expect(items.count == 1)
        #expect(items.first?.id == item.id)
    }

    @MainActor
    @Test("画像なしフィルタが動作する")
    func testFetchWithoutNoPhoto() async throws {
        let container = try createTestContainer()
        let sut = ItemsSwiftDataSourceImpl(container: container)

        // 画像ありアイテム
        let itemWithImage = Item(id: "1", coordinates: nil, world: nil, spotImageName: nil, createdAt: Date(), updatedAt: Date())
        try await sut.insert(itemWithImage, imageData: Data())

        // 画像なしアイテム
        let itemWithoutImage = Item(id: "2", coordinates: nil, world: nil, spotImageName: nil, createdAt: Date(), updatedAt: Date())
        try await sut.insert(itemWithoutImage, imageData: nil)

        // 画像ありのみ取得
        let items = try await sut.fetchWithoutNoPhoto()

        #expect(items.count == 1)
        #expect(items.first?.id == "1")
    }
}

// ヘルパー
@MainActor
private func createTestContainer() throws -> ModelContainer {
    let schema = SwiftDataSchema.v1
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    return try ModelContainer(for: schema, configurations: [config])
}
```

#### Rationale

- **憲章準拠**: 憲章v1.1.0でSwift Testingが標準
- **Swift言語統合**: `@Test`, `@Suite`, `#expect`マクロで宣言的
- **非同期サポート**: async/awaitとの統合が深い

#### Migration Notes

Quick/Nimbleからの移行マッピング:
- `describe` → `@Suite`
- `it` → `@Test`
- `expect(...).to(equal(...))` → `#expect(... == ...)`
- `beforeEach` → テストメソッド内で共通セットアップ、またはヘルパー関数

#### References

- [Swift Testing Documentation](https://developer.apple.com/documentation/testing)
- [憲章 v1.1.0](../../.specify/memory/constitution.md)

---

## Summary

すべての研究トピックについて、実装方針と技術的根拠を明確にしました。主な決定事項：

1. **SwiftData採用**: CoreDataから完全移行、`@Model`マクロで宣言的なモデル定義
2. **ExternalStorage**: 画像はSwiftDataのExternalStorageで管理、CloudKit同期も自動
3. **ModelConfiguration**: CloudKit同期設定はModelConfigurationで制御、設定変更後は再起動が必要
4. **設定UI**: @AppStorageとUserDefaultsでiCloud同期のオン/オフ切り替え
5. **新規インストール扱い**: CoreDataからの自動マイグレーションは行わない
6. **Firebase拡張準備**: SyncProtocolで抽象化、将来的にFirebase同期を追加可能
7. **Swift Testing**: 憲章に従い、新規テストはSwift Testingで記述

これらの決定事項に基づき、Phase 1の実装に進むことができます。

---

## Next Steps

1. **spec.md作成**: フィーチャー仕様書を作成
2. **data-model.md作成**: データモデル定義を詳細化
3. **plan.md更新**: 実装計画を具体化
4. **Phase 1実装**: SwiftDataモデル、SwiftDataManager、DataSource実装
5. **テスト作成**: Swift Testingで単体テスト作成

---

## Risks and Mitigations

| リスク | 影響 | 緩和策 |
|--------|------|--------|
| SwiftData不安定性（iOS 17新機能） | クラッシュ、データロス | 十分なテスト、実機検証、フォールバック処理 |
| CloudKit同期の遅延 | UX低下 | ローディング表示、タイムアウト処理 |
| 既存データの破棄 | ユーザー不満 | 事前通知、エクスポート機能（将来） |
| Firebase統合の複雑性 | 開発コスト増 | Phase 2として段階的実装 |

---

## Appendix: SwiftData Best Practices

### モデル設計

```swift
// ✅ GOOD: 値型フィールド、Sendable準拠
@Model
final class ItemModel: Sendable {
    @Attribute(.unique) var id: String
    var name: String?
    var createdAt: Date
}

// ❌ BAD: リレーションシップは避ける（CloudKit同期時に不安定）
@Model
final class ItemModel {
    var world: WorldModel?  // CloudKit同期で問題が起きる可能性
}

// ✅ GOOD: 文字列IDで参照
@Model
final class ItemModel {
    var worldID: String?  // 文字列IDで参照
}
```

### クエリ最適化

```swift
// ✅ GOOD: fetchLimitで大量データを制限
let descriptor = FetchDescriptor<ItemModel>(
    sortBy: [SortDescriptor(\.createdAt, order: .reverse)],
    fetchLimit: 100
)

// ✅ GOOD: 型安全なPredicate
let predicate = #Predicate<ItemModel> { item in
    item.createdAt > Date().addingTimeInterval(-86400)  // 24時間以内
}
```

### スレッド安全性

```swift
// ✅ GOOD: @MainActorでUI更新を保証
@MainActor
final class ItemsSwiftDataSourceImpl: ItemsSwiftDataSource {
    func fetchAll() async throws -> [Item] {
        let context = ModelContext(container)
        // ...
    }
}

// ✅ GOOD: Sendableプロトコル準拠
protocol ItemsSwiftDataSource: Sendable {
    func fetchAll() async throws -> [Item]
}
```
