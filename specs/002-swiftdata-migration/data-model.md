# Data Model: CoreData → SwiftData 移行

**Feature**: 002-swiftdata-migration
**Date**: 2025-12-22
**Status**: Design Phase

## Overview

本文書は、CoreDataからSwiftDataへの移行におけるデータモデル定義をまとめたものです。

---

## Entities

### 1. ItemModel (SwiftData)

Minecraftスポット情報を表現するSwiftDataモデル。

#### Properties

| Property | Type | Description | Constraints | Default Value |
|----------|------|-------------|-------------|---------------|
| `id` | `String` | ユニークID | `@Attribute(.unique)` | - |
| `coordinatesX` | `String?` | X座標（文字列保存） | - | `nil` |
| `coordinatesY` | `String?` | Y座標（文字列保存） | - | `nil` |
| `coordinatesZ` | `String?` | Z座標（文字列保存） | - | `nil` |
| `worldID` | `String?` | 所属ワールドID（文字列参照） | - | `nil` |
| `name` | `String?` | スポット名 | - | `nil` |
| `comment` | `String?` | コメント | - | `nil` |
| `spotImageData` | `Data?` | スクリーンショット画像 | `@Attribute(.externalStorage)` | `nil` |
| `createdAt` | `Date` | 作成日時 | - | - |
| `updatedAt` | `Date` | 更新日時 | - | - |

#### Full Definition

```swift
import SwiftData
import Foundation

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

    init(
        id: String,
        coordinatesX: String? = nil,
        coordinatesY: String? = nil,
        coordinatesZ: String? = nil,
        worldID: String? = nil,
        name: String? = nil,
        comment: String? = nil,
        spotImageData: Data? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.coordinatesX = coordinatesX
        self.coordinatesY = coordinatesY
        self.coordinatesZ = coordinatesZ
        self.worldID = worldID
        self.name = name
        self.comment = comment
        self.spotImageData = spotImageData
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
```

#### Protocol Conformance

- **@Model**: SwiftDataの永続化対象マクロ
- **Sendable**: Strict Concurrency対応（クラスはfinalかつ@Modelで自動的にSendable）

#### Design Decisions

1. **リレーションシップを使わない**: CloudKit同期時の不安定性を回避するため、Worldへの参照は文字列ID（`worldID`）で管理
2. **座標を文字列保存**: 既存CoreDataの実装を踏襲（Int → String変換）
3. **ExternalStorage**: 画像はSwiftDataのExternalStorageで管理し、CloudKit同期を自動化

---

### 2. WorldModel (SwiftData)

Minecraftワールド情報を表現するSwiftDataモデル。

#### Properties

| Property | Type | Description | Constraints | Default Value |
|----------|------|-------------|-------------|---------------|
| `id` | `String` | ユニークID | `@Attribute(.unique)` | - |
| `name` | `String?` | ワールド名 | - | `nil` |
| `seed` | `String?` | シード値（文字列保存） | - | `nil` |
| `comment` | `String?` | コメント | - | `nil` |
| `createdAt` | `Date` | 作成日時 | - | - |
| `updatedAt` | `Date` | 更新日時 | - | - |

#### Full Definition

```swift
import SwiftData
import Foundation

@Model
final class WorldModel {
    @Attribute(.unique) var id: String
    var name: String?
    var seed: String?  // Seed.rawValueを文字列保存
    var comment: String?
    var createdAt: Date
    var updatedAt: Date

    init(
        id: String,
        name: String? = nil,
        seed: String? = nil,
        comment: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.seed = seed
        self.comment = comment
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
```

---

### 3. SwiftDataSchema

スキーマバージョン管理。

```swift
import SwiftData

enum SwiftDataSchema {
    static let v1 = Schema([
        ItemModel.self,
        WorldModel.self
    ])
}
```

#### Versioning Strategy

将来のスキーマ変更に対応するため、VersionedSchemaを使用可能:

```swift
enum SwiftDataSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] {
        [ItemModel.self, WorldModel.self]
    }
}

enum SwiftDataSchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(2, 0, 0)
    static var models: [any PersistentModel.Type] {
        [ItemModel.self, WorldModel.self, NewModel.self]  // 新規モデル追加
    }
}

enum SwiftDataMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [SwiftDataSchemaV1.self, SwiftDataSchemaV2.self]
    }

    static var stages: [MigrationStage] {
        [/* マイグレーション定義 */]
    }
}
```

---

## Domain Models (既存)

SwiftDataモデルとドメインモデルのマッピング。

### Item (Domain Model)

```swift
struct Item: Identifiable, Hashable, Sendable {
    var id: String
    var coordinates: Coordinates?
    var world: World?
    var spotImageName: String?  // 画像の有無を示すフラグ（SwiftDataではid使用）
    var createdAt: Date
    var updatedAt: Date
}
```

**ItemModel → Item 変換**:
```swift
extension ItemModel {
    func toDomain(world: World?) -> Item {
        let coordinates: Coordinates?
        if let x = coordinatesX.flatMap(Int.init),
           let y = coordinatesY.flatMap(Int.init),
           let z = coordinatesZ.flatMap(Int.init) {
            coordinates = Coordinates(x: x, y: y, z: z)
        } else {
            coordinates = nil
        }

        return Item(
            id: id,
            coordinates: coordinates,
            world: world,
            spotImageName: spotImageData != nil ? id : nil,  // 画像存在フラグ
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

extension Item {
    func toModel(imageData: Data?) -> ItemModel {
        ItemModel(
            id: id,
            coordinatesX: coordinates?.x.description,
            coordinatesY: coordinates?.y.description,
            coordinatesZ: coordinates?.z.description,
            worldID: world?.id,
            spotImageData: imageData,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
```

### World (Domain Model)

```swift
struct World: Identifiable, Hashable, Sendable {
    var id: String
    var name: String?
    var seed: Seed?
    var createdAt: Date
    var updatedAt: Date
}
```

**WorldModel → World 変換**:
```swift
extension WorldModel {
    func toDomain() -> World {
        World(
            id: id,
            name: name,
            seed: seed.flatMap { Seed($0) },
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

extension World {
    func toModel() -> WorldModel {
        WorldModel(
            id: id,
            name: name,
            seed: seed?.rawValue.description,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
```

---

## Relationships

### データフロー

```
UI Layer (SwiftUI Views)
    ↓
ViewModel (@Observable)
    ↓
UseCase (Domain Layer)
    ↓
Repository (Data Layer)
    ↓
SwiftDataSource
    ↓
ModelContext (SwiftData)
    ↓
ItemModel / WorldModel (@Model)
    ↓
ModelContainer
    ↓ (if CloudKit enabled)
CloudKit Private Database
```

### 参照関係

```
ItemModel
    └─ worldID: String?  (WorldModelへの参照)

WorldModel
    (Itemからの逆参照なし)
```

**注意**: リレーションシップ（`@Relationship`）は使用せず、文字列IDで参照管理。これにより、CloudKit同期時の安定性を向上。

---

## Storage Format

### ModelContainer Configuration

```swift
// iCloud同期有効
let config = ModelConfiguration(
    schema: SwiftDataSchema.v1,
    cloudKitDatabase: .automatic
)

// ローカルのみ
let config = ModelConfiguration(
    schema: SwiftDataSchema.v1,
    cloudKitDatabase: .none
)

let container = try ModelContainer(for: SwiftDataSchema.v1, configurations: [config])
```

### ExternalStorage

画像データは自動的にSwiftDataのExternalStorageに保存される:

- **保存先**: ModelContainerのディレクトリ内の専用領域
- **CloudKit同期**: ExternalStorageのデータも自動的にCloudKitでアップロード/ダウンロード
- **削除**: エンティティ削除時に自動的に削除

---

## Migration Strategy

### CoreData → SwiftData マイグレーション（将来実装の場合）

```swift
func migrateCoreDataToSwiftData() async throws {
    let coreDataContext = CoreDataManager.shared.viewContext
    let swiftDataContext = ModelContext(SwiftDataManager.shared.container)

    // ItemEntity → ItemModel
    let fetchRequest: NSFetchRequest<ItemEntity> = ItemEntity.fetchRequest()
    let coreDataItems = try coreDataContext.fetch(fetchRequest)

    for coreDataItem in coreDataItems {
        let imageData: Data?
        if let imageName = coreDataItem.spotImageName {
            // ファイルシステムから画像読み込み
            imageData = try? LocalImageRepository().loadImageData(fileName: imageName)
        } else {
            imageData = nil
        }

        let swiftDataItem = ItemModel(
            id: coreDataItem.id?.uuidString ?? UUID().uuidString,
            coordinatesX: coreDataItem.coordinatesX,
            coordinatesY: coreDataItem.coordinatesY,
            coordinatesZ: coreDataItem.coordinatesZ,
            worldID: coreDataItem.world?.uuidString,
            spotImageData: imageData,
            createdAt: coreDataItem.createdAt ?? Date(),
            updatedAt: coreDataItem.updatedAt ?? Date()
        )
        swiftDataContext.insert(swiftDataItem)
    }

    try swiftDataContext.save()
}
```

**注意**: 今回は新規インストール扱いのため、このマイグレーションは実装しない。

---

## Testing Strategy

### Unit Tests

```swift
import Testing
import SwiftData
@testable import AppFeature

@Suite("ItemModel Tests")
struct ItemModelTests {

    @MainActor
    @Test("ItemModelを作成して保存できる")
    func testCreateAndSave() async throws {
        let container = try createTestContainer()
        let context = ModelContext(container)

        let item = ItemModel(
            id: "test-id",
            coordinatesX: "100",
            coordinatesY: "64",
            coordinatesZ: "200",
            worldID: "world-id",
            spotImageData: Data(),
            createdAt: Date(),
            updatedAt: Date()
        )

        context.insert(item)
        try context.save()

        // 取得確認
        let descriptor = FetchDescriptor<ItemModel>(
            predicate: #Predicate { $0.id == "test-id" }
        )
        let items = try context.fetch(descriptor)

        #expect(items.count == 1)
        #expect(items.first?.id == "test-id")
        #expect(items.first?.coordinatesX == "100")
    }

    @MainActor
    @Test("画像を保存・読み込みできる")
    func testImageStorage() async throws {
        let container = try createTestContainer()
        let context = ModelContext(container)

        let imageData = Data([0x01, 0x02, 0x03])
        let item = ItemModel(
            id: "test-id",
            spotImageData: imageData,
            createdAt: Date(),
            updatedAt: Date()
        )

        context.insert(item)
        try context.save()

        // 再取得
        let descriptor = FetchDescriptor<ItemModel>(
            predicate: #Predicate { $0.id == "test-id" }
        )
        let items = try context.fetch(descriptor)

        #expect(items.first?.spotImageData == imageData)
    }
}

@MainActor
private func createTestContainer() throws -> ModelContainer {
    let schema = SwiftDataSchema.v1
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    return try ModelContainer(for: schema, configurations: [config])
}
```

### Test Fixtures

```swift
extension ItemModel {
    static func testFixture(
        id: String = UUID().uuidString,
        coordinatesX: String? = "100",
        coordinatesY: String? = "64",
        coordinatesZ: String? = "200",
        worldID: String? = nil,
        spotImageData: Data? = nil
    ) -> ItemModel {
        ItemModel(
            id: id,
            coordinatesX: coordinatesX,
            coordinatesY: coordinatesY,
            coordinatesZ: coordinatesZ,
            worldID: worldID,
            spotImageData: spotImageData,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}
```

---

## Performance Considerations

### クエリ最適化

```swift
// ✅ GOOD: fetchLimitで大量データを制限
let descriptor = FetchDescriptor<ItemModel>(
    sortBy: [SortDescriptor(\.createdAt, order: .reverse)],
    fetchLimit: 100
)

// ✅ GOOD: 必要なプロパティのみフェッチ（将来的に）
// SwiftDataは現時点でpartial fetchingをサポートしていないが、将来対応可能性あり
```

### メモリ管理

- **Fault機構**: SwiftDataは自動的に未使用データをメモリから解放
- **ExternalStorage**: 画像は必要な時のみメモリにロード
- **バッチ処理**: 大量データ処理時は小分けにフェッチ

---

## Summary

- **ItemModel**: Minecraftスポット情報（SwiftData `@Model`）
- **WorldModel**: ワールド情報（SwiftData `@Model`）
- **ExternalStorage**: 画像をSwiftDataで自動管理
- **CloudKit同期**: ModelConfigurationで制御
- **リレーションシップ**: 文字列IDで参照（CloudKit同期の安定性向上）
- **Testing**: Swift Testingでインメモリコンテナテスト

これらのデータモデルに基づき、DataSource、Repository、UseCaseを実装します。
