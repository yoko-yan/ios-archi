# Tasks: CoreData → SwiftData 移行

**Input**: Design documents from `/specs/002-swiftdata-migration/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, quickstart.md

**Organization**: Tasks are grouped by user story to enable independent implementation and testing.

**Tests**: テストタスクは含まれていません（仕様書で明示的に要求されていないため）。ただし、各フェーズで動作確認のためのテストは推奨されます。

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3, US4)
- Include exact file paths in descriptions

## Path Conventions

- iOS project: `Package/Sources/AppFeature/`, `App/ios-archi/`
- Tests: `Package/Tests/AppFeatureTests/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: プロジェクト初期化とブランチセットアップ

- [X] T001 新しいフィーチャーブランチ 002-swiftdata-migration を作成
- [X] T002 SwiftDataディレクトリ構造を作成 (Package/Sources/AppFeature/Data/DataSource/Local/SwiftData/)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: すべてのユーザーストーリーの実装前に必須の基盤コンポーネント

**⚠️ CRITICAL**: このフェーズが完了するまで、いかなるユーザーストーリーの作業も開始できません

### SwiftDataモデル定義

- [X] T003 [P] ItemModelを作成 in Package/Sources/AppFeature/Data/DataSource/Local/SwiftData/Models/ItemModel.swift
- [X] T004 [P] WorldModelを作成 in Package/Sources/AppFeature/Data/DataSource/Local/SwiftData/Models/WorldModel.swift
- [X] T005 SwiftDataSchemaを作成 in Package/Sources/AppFeature/Data/DataSource/Local/SwiftData/SwiftDataSchema.swift

### SwiftDataManager実装

- [X] T006 SwiftDataManagerを実装（ModelContainer管理、CloudKit設定切り替え、通知監視）in Package/Sources/AppFeature/Data/DataSource/Local/SwiftData/SwiftDataManager.swift

### DataSource実装

- [X] T007 [P] ItemsSwiftDataSourceプロトコルと実装を作成（fetchAll, fetchWithoutNoPhoto, insert, update, delete）in Package/Sources/AppFeature/Data/DataSource/Local/SwiftData/ItemsSwiftDataSource.swift
- [X] T008 [P] WorldsSwiftDataSourceプロトコルと実装を作成（CRUD操作）in Package/Sources/AppFeature/Data/DataSource/Local/SwiftData/WorldsSwiftDataSource.swift

### Repository層更新

- [X] T009 ItemsRepositoryを更新（insert/updateに画像パラメータ追加、SwiftDataSource使用）in Package/Sources/AppFeature/Data/Repository/ItemsRepository.swift
- [X] T010 WorldsRepositoryを更新（SwiftDataSource使用）in Package/Sources/AppFeature/Data/Repository/WorldsRepository.swift

**Checkpoint**: Foundation ready - ユーザーストーリーの実装を開始可能

---

## Phase 3: User Story 1 - iCloud同期のオン/オフ切り替え (Priority: P1) 🎯 MVP

**Goal**: ユーザーが設定画面でiCloud同期のオン/オフを切り替えられるようにする

**Independent Test**:
1. 設定画面を開く
2. iCloud同期トグルスイッチが表示されることを確認
3. トグルをON/OFFに切り替える
4. アプリ再起動を促すメッセージが表示されることを確認
5. アプリを再起動
6. 設定が保持されていることを確認（UserDefaultsで確認可能）

### Implementation for User Story 1

- [X] T011 [P] [US1] SettingsViewを作成（iCloud同期トグル、再起動案内表示）in Package/Sources/AppFeature/UI/Settings/SettingsView.swift
- [X] T012 [US1] RootViewを更新（SettingsViewをTabViewに統合、modelContainer注入）in Package/Sources/AppFeature/UI/RootView/RootView.swift
- [X] T013 [US1] SwiftDataManagerの通知監視が正しく動作することを確認（トグル変更時に通知が発行され、再起動後に設定が反映される）

**Checkpoint**: User Story 1が完全に機能し、独立してテスト可能

---

## Phase 4: User Story 2 - 画像の自動同期 (Priority: P2)

**Goal**: 画像が自動的にiCloudで同期される

**Independent Test**:
1. デバイスAで画像付きアイテムを作成
2. デバイスBで同じiCloudアカウントにログイン
3. デバイスBでアプリを起動し、同期を待つ（数秒〜数分）
4. デバイスBで画像付きアイテムが表示されることを確認
5. デバイスBで画像が正しく表示されることを確認
6. デバイスAでアイテムを削除
7. デバイスBで削除が同期されることを確認

### Implementation for User Story 2

- [ ] T014 [P] [US2] SaveSpotImageUseCaseを更新（画像データ変換の責務として残すか、削除するかを決定）in Package/Sources/AppFeature/Domain/SaveSpotImageUseCase.swift
- [ ] T015 [P] [US2] LoadSpotImageUseCaseを更新（SwiftDataからspotImageDataを読み込み、UIImageに変換）in Package/Sources/AppFeature/Domain/LoadSpotImageUseCase.swift
- [ ] T016 [US2] ItemEditViewModelを更新（itemsRepository.insert/updateに画像を渡すように変更）in Package/Sources/AppFeature/UI/ItemEdit/ItemEditViewModel.swift
- [ ] T017 [US2] ItemDetailViewModelを更新（itemsRepository.updateに画像を渡すように変更）in Package/Sources/AppFeature/UI/ItemDetail/ItemDetailViewModel.swift
- [ ] T018 [US2] 実機で2台のデバイス間でCloudKit同期をテスト（画像付きアイテムが同期されることを確認）

**Checkpoint**: User Story 2が完全に機能し、User Story 1と独立してテスト可能

---

## Phase 5: User Story 3 - データ移行時の通知 (Priority: P3)

**Goal**: アプリ更新時にデータがリセットされることをユーザーに事前通知

**Independent Test**:
1. App Storeのアップデート説明文に「データリセット」の記載があることを確認
2. （オプション）初回起動時に警告ダイアログが表示されることを確認

### Implementation for User Story 3

- [ ] T019 [US3] App Store説明文のドラフトを作成（データリセットの旨を記載）in /Users/apla/workspace/projects/source/ios-archi_/docs/app-store-description.md (新規作成)
- [ ] T020 [US3] （オプション）初回起動時の警告ダイアログをRootViewModelに追加 in Package/Sources/AppFeature/UI/RootView/RootViewModel.swift

**Checkpoint**: User Story 3が完全に機能

---

## Phase 6: User Story 4 - 開発者向け設定調整 (Priority: P4)

**Goal**: コード内でiCloud同期のオン/オフを切り替えてテスト可能にする

**Independent Test**:
1. UserDefaults.standard.set(true, forKey: "iCloudSyncEnabled") をコードで実行
2. アプリを再起動
3. SwiftDataManagerが正しくCloudKit同期を有効化していることを確認
4. UserDefaults.standard.set(false, forKey: "iCloudSyncEnabled") をコードで実行
5. アプリを再起動
6. SwiftDataManagerがローカルのみで動作していることを確認

### Implementation for User Story 4

- [ ] T021 [US4] デバッグビルドでのデフォルト設定変更機能を追加（#if DEBUG でUserDefaults初期値を変更可能に）in Package/Sources/AppFeature/Data/DataSource/Local/SwiftData/SwiftDataManager.swift
- [ ] T022 [US4] 開発者向けドキュメントにiCloud同期設定のテスト方法を記載 in /Users/apla/workspace/projects/source/ios-archi_/docs/developer-testing-guide.md (新規作成)

**Checkpoint**: すべてのユーザーストーリーが独立して機能

---

## Phase 7: Integration & Cloud Sync

**Purpose**: UseCaseの更新とクラウド同期の統合

- [ ] T023 SynchronizeWithCloudUseCaseを更新（SwiftDataのCloudKit同期待機処理に変更）in Package/Sources/AppFeature/Domain/SynchronizeWithCloudUseCase.swift
- [ ] T024 実機で2台のデバイス間でCloudKit同期の全機能をテスト（アイテム作成、更新、削除、画像同期）

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: 複数のユーザーストーリーに影響する改善

- [ ] T025 [P] CoreDataManager削除 in Package/Sources/AppFeature/Data/DataSource/Local/CoreData/CoreDataManager.swift
- [ ] T026 [P] CoreDataモデル削除 in Package/Sources/AppFeature/Data/DataSource/Local/CoreData/Model.xcdatamodeld
- [ ] T027 [P] ItemsLocalDataSource削除 in Package/Sources/AppFeature/Data/DataSource/Local/ItemsLocalDataSource.swift
- [ ] T028 [P] WorldsLocalDataSource削除 in Package/Sources/AppFeature/Data/DataSource/Local/WorldsLocalDataSource.swift
- [ ] T029 [P] LocalDataSource削除 in Package/Sources/AppFeature/Data/DataSource/Local/LocalDataSource.swift
- [ ] T030 [P] LocalImageRepository削除 in Package/Sources/AppFeature/Data/Repository/ImageRepository/LocalImageRepository.swift
- [ ] T031 [P] ICloudDocumentRepository削除 in Package/Sources/AppFeature/Data/Repository/ImageRepository/ICloudDocumentRepository.swift
- [ ] T032 CLAUDE.mdを更新（CoreData → SwiftData、CloudKit設定、設定画面の説明を追加）in /Users/apla/workspace/projects/source/ios-archi_/CLAUDE.md
- [ ] T033 SwiftLintを実行してコード品質を確認
- [ ] T034 SwiftFormatを実行してコードフォーマットを確認
- [ ] T035 ビルドが成功することを確認（xcodebuild build）
- [ ] T036 すべての既存テストがパスすることを確認（xcodebuild test）
- [ ] T037 quickstart.mdの検証手順を実行（実機テスト、CloudKit同期、iCloud設定切り替え）

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3-6)**: All depend on Foundational phase completion
  - User stories can then proceed in parallel (if staffed)
  - Or sequentially in priority order (US1 → US2 → US3 → US4)
- **Integration (Phase 7)**: Depends on US1 and US2 completion
- **Polish (Phase 8)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (US1 - 設定UI)**: Depends on Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (US2 - 画像同期)**: Depends on Foundational (Phase 2) - No dependencies on other stories (独立してテスト可能)
- **User Story 3 (US3 - 通知)**: Depends on Foundational (Phase 2) - No dependencies on other stories
- **User Story 4 (US4 - 開発者設定)**: Depends on Foundational (Phase 2) - No dependencies on other stories

### Within Each User Story

- US1: SettingsView → RootView統合 → 動作確認
- US2: UseCase更新（並列） → ViewModel更新 → 実機テスト
- US3: App Store説明文 → （オプション）警告ダイアログ
- US4: デバッグ設定 → ドキュメント

### Parallel Opportunities

- **Phase 1 Setup**: すべてのタスク並列実行可能
- **Phase 2 Foundational**:
  - T003 (ItemModel) と T004 (WorldModel) 並列
  - T007 (ItemsSwiftDataSource) と T008 (WorldsSwiftDataSource) 並列
- **Phase 3-6 User Stories**: US1, US2, US3, US4 はすべて並列実行可能（Foundational完了後）
- **Phase 7 Integration**: US1とUS2完了後に開始
- **Phase 8 Polish**: T025-T031（CoreData削除タスク）はすべて並列実行可能

---

## Parallel Example: User Story 2

```bash
# Launch UseCase更新タスクを並列実行:
Task T014: "SaveSpotImageUseCaseを更新"
Task T015: "LoadSpotImageUseCaseを更新"

# Launch ViewModel更新タスクを並列実行:
Task T016: "ItemEditViewModelを更新"
Task T017: "ItemDetailViewModelを更新"
```

---

## Parallel Example: Phase 8 (CoreData削除)

```bash
# Launch すべての削除タスクを並列実行:
Task T025: "CoreDataManager削除"
Task T026: "CoreDataモデル削除"
Task T027: "ItemsLocalDataSource削除"
Task T028: "WorldsLocalDataSource削除"
Task T029: "LocalDataSource削除"
Task T030: "LocalImageRepository削除"
Task T031: "ICloudDocumentRepository削除"
```

---

## Implementation Strategy

### MVP First (User Story 1 のみ)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - すべてのストーリーをブロック)
3. Complete Phase 3: User Story 1（設定UI）
4. **STOP and VALIDATE**: User Story 1を独立してテスト
5. 必要に応じてデプロイ/デモ

### Incremental Delivery

1. Complete Setup + Foundational → 基盤完成
2. Add User Story 1 → 独立してテスト → デプロイ/デモ (MVP!)
3. Add User Story 2 → 独立してテスト → デプロイ/デモ
4. Add User Story 3 → 独立してテスト → デプロイ/デモ
5. Add User Story 4 → 独立してテスト → デプロイ/デモ
6. Complete Integration (Phase 7) → 全体統合テスト
7. Complete Polish (Phase 8) → クリーンアップとリリース準備
8. 各ストーリーは前のストーリーを壊さずに価値を追加

### Parallel Team Strategy

複数の開発者がいる場合:

1. チーム全員で Setup + Foundational を完了
2. Foundational完了後:
   - Developer A: User Story 1（設定UI）
   - Developer B: User Story 2（画像同期）
   - Developer C: User Story 3 & 4（通知と開発者設定）
3. ストーリーが完了したら独立して統合

---

## Notes

- [P] タスク = 異なるファイル、依存関係なし、並列実行可能
- [Story] ラベル = 特定のユーザーストーリーへのタスクマッピング
- 各ユーザーストーリーは独立して完了可能でテスト可能
- 各タスクまたは論理的なグループ後にコミット
- 任意のチェックポイントで停止し、ストーリーを独立して検証可能
- 避けるべき: 曖昧なタスク、同じファイルの競合、ストーリーの独立性を壊す依存関係

---

## Total Task Count

**合計タスク数**: 37タスク

**ユーザーストーリー別タスク数**:
- User Story 1（設定UI）: 3タスク
- User Story 2（画像同期）: 5タスク
- User Story 3（通知）: 2タスク
- User Story 4（開発者設定）: 2タスク
- Foundational（基盤）: 8タスク
- Integration（統合）: 2タスク
- Polish（クリーンアップ）: 13タスク
- Setup（セットアップ）: 2タスク

**並列実行の機会**:
- Phase 2: 4つのタスクが並列実行可能（ItemModel/WorldModel、ItemsDataSource/WorldsDataSource）
- Phase 3-6: 4つのユーザーストーリーがすべて並列実行可能
- Phase 8: 7つの削除タスクが並列実行可能

**推奨MVPスコープ**: Phase 1 + Phase 2 + Phase 3（User Story 1のみ） = 13タスク
