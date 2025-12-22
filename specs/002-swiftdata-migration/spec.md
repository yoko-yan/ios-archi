# Feature Specification: CoreData → SwiftData 移行

**Feature ID**: 002-swiftdata-migration
**Status**: Planning
**Created**: 2025-12-22
**Updated**: 2025-12-22

## Overview

現在のCoreData + CloudKit実装をSwiftDataベースに移行し、iCloud同期を設定画面でオン/オフ切り替え可能にする。将来的なFirebase同期拡張も見据えた拡張可能な設計を行う。

## Problem Statement

現在、アプリではNSPersistentCloudKitContainerを使用したCoreDataでデータ永続化を行っているが、以下の課題がある：

1. **CoreDataの複雑性**: NSManagedObjectContext、NSFetchRequestなど、ボイラープレートが多い
2. **CloudKit同期の固定化**: iCloud同期のオン/オフをユーザーが選択できない
3. **画像管理の分離**: 画像がファイルシステムに別管理され、CloudKit同期が煩雑
4. **将来の拡張性**: Firebase同期など、他の同期プロバイダーへの拡張が困難

これにより、コードの保守性が低く、ユーザーのニーズに柔軟に対応できない。

## Goals

### Primary Goals

1. **SwiftData移行**: CoreDataからSwiftDataへ完全移行し、コードをシンプル化
2. **iCloud同期設定**: 設定画面でiCloud同期のオン/オフを切り替え可能に
3. **画像のExternalStorage管理**: 画像をSwiftDataのExternalStorageで管理し、CloudKit同期を自動化
4. **拡張可能な設計**: 将来的にFirebase同期を追加できるアーキテクチャ

### Non-Goals

- Firebase同期の実装（将来拡張のためのアーキテクチャのみ考慮）
- 既存データのマイグレーション（新規インストール扱い）
- クラウド同期された設定（設定はローカルのみ）
- 複数デバイス間での設定同期

## User Stories

### US-1: iCloud同期のオン/オフ切り替え

**As a** ユーザー
**I want to** iCloud同期のオン/オフを設定画面で切り替えられる
**So that** データをローカルのみで管理するか、複数デバイスで同期するかを選択できる

**Acceptance Criteria**:
- [ ] 設定画面でiCloud同期のトグルスイッチがある
- [ ] トグルをONにすると、iCloud同期が有効になる
- [ ] トグルをOFFにすると、ローカルのみで動作する
- [ ] 設定変更後、アプリ再起動を促すメッセージが表示される
- [ ] 再起動後、設定が反映される

### US-2: 画像の自動同期

**As a** ユーザー
**I want to** 画像が自動的にiCloudで同期される
**So that** 複数デバイスで同じ画像を見ることができる

**Acceptance Criteria**:
- [ ] デバイスAで画像付きアイテムを作成
- [ ] デバイスBで同じアイテムが表示される
- [ ] デバイスBで画像が正しく表示される
- [ ] アイテムを削除すると、画像も自動的に削除される

### US-3: データ移行時の通知

**As a** ユーザー
**I want to** アプリ更新時にデータがリセットされることを事前に知りたい
**So that** 重要なデータをバックアップできる

**Acceptance Criteria**:
- [ ] App Storeのアップデート説明文に「データリセット」の記載がある
- [ ] 初回起動時に警告ダイアログが表示される（オプション）

### US-4: 開発者向け設定調整

**As a** 開発者
**I want to** コード内でiCloud同期のオン/オフを切り替えられる
**So that** 実装時に様々な設定パターンをテストできる

**Acceptance Criteria**:
- [ ] UserDefaults.standard.set(true, forKey: "iCloudSyncEnabled")で設定変更できる
- [ ] アプリ再起動で設定が反映される
- [ ] デバッグビルドでデフォルト設定を変更できる

## Functional Requirements

### FR-1: SwiftDataモデル定義

既存のCoreDataエンティティをSwiftDataの`@Model`で再定義する。

**モデル**:
- **ItemModel**: id, coordinatesX/Y/Z, worldID, name, comment, spotImageData, createdAt, updatedAt
- **WorldModel**: id, name, seed, comment, createdAt, updatedAt

**制約**:
- `@Attribute(.unique)` でidをユニーク制約
- `@Attribute(.externalStorage)` で画像をExternalStorage管理
- Sendable準拠（Strict Concurrency対応）

### FR-2: SwiftDataManager実装

ModelContainerを管理し、CloudKit同期設定を制御する。

**機能**:
- ModelContainerの初期化
- CloudKit同期のオン/オフ設定
- 設定変更通知の監視
- アプリ再起動の必要性を通知

### FR-3: DataSource層実装

SwiftDataのModelContextを使用してCRUD操作を実装する。

**DataSource**:
- **ItemsSwiftDataSource**: Item の CRUD 操作
- **WorldsSwiftDataSource**: World の CRUD 操作

**機能**:
- fetchAll: 全データ取得
- fetchWithoutNoPhoto: 画像ありのデータのみ取得
- insert: データ挿入
- update: データ更新
- delete: データ削除

### FR-4: Repository層更新

既存のRepositoryインターフェースを維持し、DataSourceをSwiftData版に差し替える。

**変更点**:
- ItemsRepository.insert/update に画像パラメータを追加
- DataSourceをItemsSwiftDataSourceに変更
- 画像保存処理をRepository内で完結

### FR-5: 設定UI実装

SwiftUIで設定画面を作成し、iCloud同期のトグル切り替えを提供する。

**UI要素**:
- iCloud同期トグルスイッチ
- 設定変更後の再起動案内メッセージ
- フッターに説明文

### FR-6: UseCase更新

既存のUseCaseをSwiftData対応に更新する。

**UseCase**:
- **SaveSpotImageUseCase**: 画像をDataに変換（またはRepository統合で削除）
- **LoadSpotImageUseCase**: SwiftDataから画像を読み込み
- **SynchronizeWithCloudUseCase**: SwiftDataのCloudKit同期待機処理に変更

### FR-7: 将来のFirebase拡張準備（アーキテクチャのみ）

SyncProtocolで同期処理を抽象化し、CloudKitとFirebaseを切り替え可能にする。

**アーキテクチャ**:
- SyncManagerプロトコル定義
- CloudKitSyncManager実装
- FirebaseSyncManager（将来実装）のインターフェース定義

## Technical Requirements

### TR-1: アーキテクチャ

MVVM + Layered Architectureに従う。

**レイヤー構成**:
- Model層: ItemModel, WorldModel（SwiftData `@Model`）
- Data層: SwiftDataManager, ItemsSwiftDataSource, WorldsSwiftDataSource, Repository
- Domain層: UseCases
- UI層: SettingsView, 既存Viewの更新

### TR-2: 依存性注入

swift-dependenciesを継続使用。

**DI対象**:
- ItemsRepository
- WorldsRepository
- GetCameraSettingsUseCase（既存）
- その他UseCases

### TR-3: テスト

Swift Testingを使用（憲章準拠）。

**テスト対象**:
- SwiftDataSourceのCRUD操作
- Repository層のロジック
- UseCase層のビジネスロジック
- ViewModel層のUI状態管理

**テスト戦略**:
- インメモリModelContainerでテスト
- swift-dependenciesでモック化

### TR-4: 後方互換性

既存のUIは変更最小限とし、Repository層以下を差し替える。

**戦略**:
- ViewModelは既存のまま（可能な限り）
- Repository インターフェースは維持
- DataSourceのみSwiftData版に差し替え

## Non-Functional Requirements

### NFR-1: パフォーマンス

- データ読み込み時間: 100ms以内（既存と同等）
- CloudKit同期時間: データ量に応じて数秒〜数分（SwiftData標準）
- 画像表示遅延: 既存と同等

### NFR-2: ユーザビリティ

- 設定画面は直感的で分かりやすい
- 設定変更の影響を明確に説明
- アプリ再起動の必要性を明示

### NFR-3: 信頼性

- データロスを防ぐ（アプリ再起動後も設定保持）
- CloudKit同期エラー時の適切なハンドリング
- アプリクラッシュを引き起こさない

### NFR-4: 保守性

- SwiftLint/SwiftFormat準拠
- Strict Concurrency Checking対応
- 十分なコメントとドキュメント

## Success Criteria

1. ✅ SwiftDataモデルが定義され、テストが通る
2. ✅ SwiftDataManagerがCloudKit同期を制御できる
3. ✅ DataSource層のCRUD操作が動作する
4. ✅ Repository層が既存インターフェースを維持し、SwiftDataを使用
5. ✅ 設定画面でiCloud同期のオン/オフが切り替えられる
6. ✅ 実機で2台のデバイス間でCloudKit同期が動作する
7. ✅ 画像がExternalStorageで管理され、CloudKit同期される
8. ✅ すべてのテストがパスする
9. ✅ SwiftLint/SwiftFormatチェックがパスする

## Out of Scope

以下は本機能の範囲外とする：

- Firebase同期の実装（アーキテクチャのみ準備）
- 既存データのマイグレーション
- 設定のクラウド同期
- データのエクスポート/インポート機能
- 競合解決のカスタマイズ
- オフライン対応の拡張

## Dependencies

### External Dependencies

- SwiftData（iOS 17+）
- CloudKit（既存）
- swift-dependencies（既存）
- Swift Testing（既存）

### Internal Dependencies

- 既存のドメインモデル（Item, World, Seed, Coordinates）
- 既存のViewModel実装
- 既存のUI実装

## Risks and Mitigations

### Risk 1: SwiftDataの不安定性

**リスク**: iOS 17の新機能のため、バグやクラッシュの可能性

**緩和策**: 十分なテスト、実機検証、フォールバック処理

### Risk 2: CloudKit同期の遅延

**リスク**: データ量が多いと同期に時間がかかる

**緩和策**: ローディング表示、タイムアウト処理、ユーザーへの説明

### Risk 3: 既存データの破棄

**リスク**: ユーザーがデータを失う

**緩和策**: 事前通知、エクスポート機能（将来）、段階的ロールアウト

### Risk 4: Firebase統合の複雑性

**リスク**: Firebase同期の実装が予想以上に複雑

**緩和策**: Phase 2として段階的実装、SyncProtocol抽象化で影響を局所化

## Timeline

### Phase 1: SwiftData基盤構築（2日）

- SwiftDataモデル定義
- SwiftDataManager実装
- DataSource実装
- テスト作成

### Phase 2: Repository層更新（1日）

- ItemsRepository更新
- WorldsRepository更新
- テスト更新

### Phase 3: UseCase更新（1日）

- SaveSpotImageUseCase更新/削除
- LoadSpotImageUseCase更新
- SynchronizeWithCloudUseCase更新

### Phase 4: 設定UI実装（1日）

- SettingsView作成
- RootViewへの統合
- テスト

### Phase 5: UI層更新（1日）

- ViewModel更新（画像パラメータ追加）
- Preview更新

### Phase 6: 統合テストとクリーンアップ（1日）

- 実機テスト（2台のデバイスでCloudKit同期確認）
- CoreData関連削除
- ドキュメント更新
- コード品質チェック

**合計**: 7日

## References

- [SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)
- [CloudKit Documentation](https://developer.apple.com/documentation/cloudkit)
- [WWDC 2023: Meet SwiftData](https://developer.apple.com/videos/play/wwdc2023/10187/)
- プロジェクト憲章: `.specify/memory/constitution.md`
- 開発ガイド: `AGENTS.md`
