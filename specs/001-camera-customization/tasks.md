# Tasks: カメラ画面カスタマイズ機能

**Feature**: 001-camera-customization | **Branch**: `001-camera-customization` | **Date**: 2025-12-22

**入力**: `/specs/001-camera-customization/`の設計ドキュメント
**前提条件**: plan.md (必須), spec.md (必須), research.md, data-model.md, quickstart.md

**テスト**: 本プロジェクトでは**Swift Testingを使用したテストを含みます**。

**組織化**: タスクはUser Story単位でグループ化され、各ストーリーを独立して実装・テスト可能にします。

## フォーマット: `- [ ] [ID] [P?] [Story?] 説明 (ファイルパス)`

- **[P]**: 並列実行可能（異なるファイル、依存関係なし）
- **[Story]**: User Storyの識別子（例: US1, US2, US3, US4）
- 説明には必ず正確なファイルパスを含む

## パス規約

本プロジェクトは**SPMマルチモジュール構成**のiOSプロジェクトです：
- **ソースコード**: `Package/Sources/AppFeature/`
- **テスト**: `Package/Tests/AppFeatureTests/`
- **アプリターゲット**: `App/ios-archi/`

---

## Phase 1: Setup（共通基盤）

**目的**: プロジェクト初期化と基本構造の準備

- [X] T001 ブランチ確認と依存関係解決 `make bootstrap`
- [X] T002 [P] Info.plistにカメラ権限を追加 `App/ios-archi/Info.plist`

---

## Phase 2: Foundational（ブロッキング前提条件）

**目的**: **すべてのUser Story実装前に完了必須**の基盤実装

**⚠️ 重要**: このフェーズ完了後、User Story実装を開始できます

### 設定モデルと基盤レイヤー

- [ ] T003 [P] CameraSettingsモデルを作成 `Package/Sources/AppFeature/Model/CameraSettings.swift`
- [ ] T004 [P] CustomCameraUiStateモデルを作成 `Package/Sources/AppFeature/UI/Camera/CustomCameraUiState.swift`
- [ ] T005 CameraSettingsRepositoryプロトコルと実装を作成 `Package/Sources/AppFeature/Data/Repository/CameraSettingsRepository.swift`
- [ ] T006 [P] GetCameraSettingsUseCaseプロトコルと実装を作成 `Package/Sources/AppFeature/Domain/GetCameraSettingsUseCase.swift`
- [ ] T007 [P] SaveCameraSettingsUseCaseプロトコルと実装を作成 `Package/Sources/AppFeature/Domain/SaveCameraSettingsUseCase.swift`
- [ ] T008 swift-dependencies用のDI登録を追加 `Package/Sources/AppFeature/Domain/CameraSettingsDependency.swift`

### 基盤テスト

- [ ] T009 [P] CameraSettingsRepositoryのテストを作成 `Package/Tests/AppFeatureTests/Data/CameraSettingsRepositoryTests.swift`
- [ ] T010 [P] GetCameraSettingsUseCaseのテストを作成 `Package/Tests/AppFeatureTests/Domain/GetCameraSettingsUseCaseTests.swift`
- [ ] T011 [P] SaveCameraSettingsUseCaseのテストを作成 `Package/Tests/AppFeatureTests/Domain/SaveCameraSettingsUseCaseTests.swift`

**チェックポイント**: 基盤準備完了 - User Story実装を並列開始可能

---

## Phase 3: User Story 1 - OCR設定の調整（Priority: P1）🎯 MVP

**ゴール**: OCR認識精度・言語・画像圧縮サイズの設定を保存・読み込み可能にし、既存カメラでOCR設定が反映されるようにする（クイックウィン）

**独立テスト**: SeedEditViewまたはCoordinatesEditViewでカメラから画像を撮影し、設定したOCR設定（精度・言語・圧縮サイズ）が反映されてテキスト認識が行われることを確認

### User Story 1 実装

- [ ] T012 [US1] RecognizeTextLocalRequestに設定対応メソッドを追加 `Package/Sources/AppFeature/Data/Request/Local/RecognizeTextLocalRequest.swift`
- [ ] T013 [US1] UIImage+Extensionに設定対応リサイズメソッドを追加 `Package/Sources/AppFeature/Extension/UIImage+Extension.swift`
- [ ] T014 [US1] SeedEditViewModelで設定を使用したOCRを実装 `Package/Sources/AppFeature/UI/SeedEdit/SeedEditViewModel.swift`
- [ ] T015 [US1] CoordinatesEditViewModelで設定を使用したOCRを実装 `Package/Sources/AppFeature/UI/CoordinatesEditView/CoordinatesEditViewModel.swift`

**チェックポイント**: User Story 1が完全に機能し、独立してテスト可能

---

## Phase 4: User Story 2 - カメラUI設定（Priority: P2）

**ゴール**: シャッターボタン位置、フラッシュON/OFF、グリッド表示ON/OFFの設定を保存・読み込み可能にし、カスタムカメラUIで反映されるようにする

**独立テスト**: カスタムカメラを起動し、設定したボタン位置・フラッシュ・グリッドがUI上で正しく反映されることを確認

### User Story 2 実装（カスタムカメラUI基盤）

- [ ] T016 [P] [US2] CameraPreviewViewを作成（AVCaptureVideoPreviewLayerラッパー） `Package/Sources/AppFeature/UI/Camera/CameraPreviewView.swift`
- [ ] T017 [P] [US2] CameraControlsViewを作成（シャッター・フラッシュ・グリッドUI） `Package/Sources/AppFeature/UI/Camera/CameraControlsView.swift`
- [ ] T018 [US2] CustomCameraViewModelを作成（AVCaptureSession管理、UI設定反映） `Package/Sources/AppFeature/UI/Camera/CustomCameraViewModel.swift`
- [ ] T019 [US2] CustomCameraViewを作成（メイン統合View） `Package/Sources/AppFeature/UI/Camera/CustomCameraView.swift`

### User Story 2 テスト

- [ ] T020 [US2] CustomCameraViewModelのテストを作成 `Package/Tests/AppFeatureTests/UI/CustomCameraViewModelTests.swift`

**チェックポイント**: User Story 1とUser Story 2の両方が独立して動作

---

## Phase 5: User Story 3 - 撮影設定の調整（Priority: P3）

**ゴール**: 露出モード（自動/マニュアル）、フォーカスモード（自動/マニュアル）、ズーム倍率の設定を保存・読み込み可能にし、カスタムカメラで反映されるようにする

**独立テスト**: カスタムカメラを起動し、マニュアルモードで露出・フォーカス・ズームをリアルタイムに調整できることを確認

### User Story 3 実装（カメラ撮影設定）

- [ ] T021 [US3] CustomCameraViewModelに露出制御を追加 `Package/Sources/AppFeature/UI/Camera/CustomCameraViewModel.swift`
- [ ] T022 [US3] CustomCameraViewModelにフォーカス制御を追加 `Package/Sources/AppFeature/UI/Camera/CustomCameraViewModel.swift`
- [ ] T023 [US3] CustomCameraViewModelにズーム制御を追加 `Package/Sources/AppFeature/UI/Camera/CustomCameraViewModel.swift`
- [ ] T024 [US3] CameraControlsViewに撮影設定UIコントロールを追加 `Package/Sources/AppFeature/UI/Camera/CameraControlsView.swift`

**チェックポイント**: すべてのUser Story（US1, US2, US3）が独立して機能

---

## Phase 6: User Story 4 - 開発時設定調整（Priority: P4）

**ゴール**: コード内でCameraSettings.defaultを変更したり、UserDefaultsに直接値を設定することで開発時に設定を調整可能にする

**独立テスト**: CameraSettings.defaultを変更してアプリを再起動し、設定が反映されることを確認

### User Story 4 実装（開発者向け設定調整）

- [ ] T025 [US4] CameraSettings.defaultにデバッグ用設定例をコメントで追加 `Package/Sources/AppFeature/Model/CameraSettings.swift`
- [ ] T026 [US4] quickstart.mdの設定調整セクションを実装に合わせて更新 `specs/001-camera-customization/quickstart.md`

**チェックポイント**: 開発者が設定を簡単に調整できる仕組みが完成

---

## Phase 7: 統合とテスト（Polish & Cross-Cutting Concerns）

**目的**: 新旧カメラの切り替え統合と全体的な品質チェック

- [ ] T027 ImagePickerAdapterを作成（新旧カメラ切り替え） `Package/Sources/AppFeature/UI/Common/ImagePickerAdapter.swift`
- [ ] T028 SeedEditViewをImagePickerAdapter使用に更新 `Package/Sources/AppFeature/UI/SeedEdit/SeedEditView.swift`
- [ ] T029 CoordinatesEditViewをImagePickerAdapter使用に更新 `Package/Sources/AppFeature/UI/CoordinatesEditView/CoordinatesEditView.swift`
- [ ] T030 [P] すべてのテストを実行して動作確認 `xcodebuild test -workspace ios-archi.xcworkspace -scheme ios-archi`
- [ ] T031 [P] SwiftLintチェックを実行 `make lint`
- [ ] T032 [P] SwiftFormatを実行 `make format`
- [ ] T033 実機でカメラ起動・撮影・OCRの統合テスト実施
- [ ] T034 quickstart.mdの動作確認手順を実行 `specs/001-camera-customization/quickstart.md`

---

## 依存関係と実行順序

### フェーズ依存関係

- **Setup（Phase 1）**: 依存なし - すぐに開始可能
- **Foundational（Phase 2）**: Setupに依存 - **すべてのUser Storyをブロック**
- **User Stories（Phase 3-6）**: すべてFoundational完了に依存
  - User Storyは並列実行可能（チーム体制による）
  - または優先度順に実行（P1 → P2 → P3 → P4）
- **統合とテスト（Phase 7）**: 実装したいUser Storyすべてに依存

### User Story依存関係

- **User Story 1（P1）**: Foundational完了後に開始可能 - 他のStoryへの依存なし
- **User Story 2（P2）**: Foundational完了後に開始可能 - US1と独立（ただし統合時にUS1と連携）
- **User Story 3（P3）**: Foundational完了後に開始可能 - US2のカスタムカメラ基盤に機能追加
- **User Story 4（P4）**: Foundational完了後に開始可能 - 他のStoryと独立

### 各User Story内のタスク順序

- モデル → Repository → UseCase → ViewModel → View
- テストは実装と並行または実装後に作成
- User Story完了後、次の優先度に進む前に独立動作を確認

### 並列実行の機会

- Setup内の[P]タスクはすべて並列実行可能
- Foundational内の[P]タスクはすべて並列実行可能（Phase 2内）
- Foundational完了後、すべてのUser Storyを並列開始可能（チーム体制による）
- 各User Story内の[P]タスクは並列実行可能
- 異なるUser Storyは異なるチームメンバーが並列作業可能

---

## 並列実行例: Foundational（Phase 2）

```bash
# モデル作成（並列）
Task: "T003 CameraSettingsモデルを作成"
Task: "T004 CustomCameraUiStateモデルを作成"

# UseCase作成（並列、T005完了後）
Task: "T006 GetCameraSettingsUseCaseを作成"
Task: "T007 SaveCameraSettingsUseCaseを作成"

# テスト作成（並列、実装完了後）
Task: "T009 CameraSettingsRepositoryのテスト"
Task: "T010 GetCameraSettingsUseCaseのテスト"
Task: "T011 SaveCameraSettingsUseCaseのテスト"
```

---

## 並列実行例: User Story 2（Phase 4）

```bash
# UI View作成（並列）
Task: "T016 CameraPreviewViewを作成"
Task: "T017 CameraControlsViewを作成"

# ViewModel作成（T016, T017完了後）
Task: "T018 CustomCameraViewModelを作成"
```

---

## 実装戦略

### MVP First（User Story 1のみ）

1. Phase 1完了: Setup
2. Phase 2完了: Foundational（重要 - すべてのStoryをブロック）
3. Phase 3完了: User Story 1（OCR設定の調整）
4. **ストップして検証**: User Story 1を独立テスト
5. 準備ができたらデプロイ/デモ

### インクリメンタルデリバリー

1. Setup + Foundational完了 → 基盤準備完了
2. User Story 1追加 → 独立テスト → デプロイ/デモ（MVP！）
3. User Story 2追加 → 独立テスト → デプロイ/デモ
4. User Story 3追加 → 独立テスト → デプロイ/デモ
5. User Story 4追加 → 独立テスト → デプロイ/デモ
6. 各Storyが前のStoryを壊さずに価値を追加

### 並列チーム戦略

複数の開発者がいる場合：

1. チーム全員でSetup + Foundationalを完了
2. Foundational完了後：
   - 開発者A: User Story 1
   - 開発者B: User Story 2
   - 開発者C: User Story 3
3. Storyを独立して完了・統合

---

## Notes

- **[P]タスク**: 異なるファイル、依存関係なし
- **[Story]ラベル**: タスクを特定のUser Storyにマッピング（トレーサビリティ）
- **各User Storyは独立して完了・テスト可能**
- **テスト**: Swift Testingを使用してすべてのテストを記述
- **コミット**: 各タスクまたは論理グループ完了後にコミット
- **チェックポイント**: 各Storyを独立して検証するために任意のチェックポイントで停止
- **避けるべき**: 曖昧なタスク、同一ファイルの競合、Story独立性を壊すクロスStory依存

---

## 実装ガイド

- **設定調整方法**: [quickstart.md](./quickstart.md#設定の調整開発時) を参照
- **テスト実行方法**: [quickstart.md](./quickstart.md#テストの実行) を参照
- **開発環境セットアップ**: [quickstart.md](./quickstart.md#setup) を参照
- **技術的な設計判断**: [research.md](./research.md) を参照
- **データモデル定義**: [data-model.md](./data-model.md) を参照
- **全体的な実装計画**: [plan.md](./plan.md) を参照

---

## タスク統計

- **総タスク数**: 34
- **Setup**: 2タスク
- **Foundational**: 9タスク
- **User Story 1 (P1)**: 4タスク
- **User Story 2 (P2)**: 5タスク
- **User Story 3 (P3)**: 4タスク
- **User Story 4 (P4)**: 2タスク
- **統合とテスト**: 8タスク
- **並列実行可能**: 13タスク
- **推奨MVPスコープ**: Phase 1 + Phase 2 + Phase 3（User Story 1）

---

## Success Criteria（成功基準）

本機能は以下をすべて満たしたときに完了とします：

- [ ] すべてのUser Storiesが完了している（US-1, US-2, US-3, US-4）
- [ ] すべてのSwift Testingテストがパスしている
- [ ] SwiftLint/SwiftFormatチェックがパスしている
- [ ] Strict Concurrencyチェックでビルドが通る
- [ ] 既存のSeedEditView、CoordinatesEditViewで正常に動作する
- [ ] カメラ権限がない場合も適切に処理される
- [ ] シミュレータでもビルドエラーが発生しない
- [ ] 実機でカメラが正常に起動・撮影できる
- [ ] OCR設定が正しく反映される
- [ ] カスタムカメラUIがすべての設定を反映する

---

**生成日時**: 2025-12-22
**フォーマット検証**: ✅ すべてのタスクがチェックリスト形式（`- [ ]`）に準拠
**User Story組織化**: ✅ 各Storyが独立してテスト可能
**並列化最適化**: ✅ 13個の[P]タスクを識別
