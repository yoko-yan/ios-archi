# Feature Specification: カメラ画面カスタマイズ機能

**Feature ID**: 001-camera-customization
**Status**: Planning
**Created**: 2025-12-22
**Updated**: 2025-12-22

## Overview

カメラ画面のカスタマイズ機能を追加し、ユーザーがOCR設定、カメラUI、撮影設定を調整できるようにする。設定はアプリ全体で共通の設定として保存される。

## Problem Statement

現在、アプリではUIImagePickerControllerを使用したカメラ機能を提供しているが、以下の課題がある：

1. **OCR設定の固定化**: 認識精度、認識言語、画像圧縮サイズがコードに固定されており、ユーザーが調整できない
2. **カメラUIの限定性**: UIImagePickerControllerの標準UIのみで、カスタマイズができない
3. **撮影設定の不足**: 露出、フォーカス、ズームなどの細かい調整ができない

これにより、様々な撮影環境や用途に対応できず、ユーザー体験が制限されている。

## Goals

### Primary Goals

1. **OCR設定のカスタマイズ**: ユーザーが認識精度、言語、画像サイズを調整可能にする
2. **カメラUIのカスタマイズ**: シャッターボタン位置、フラッシュ、グリッド表示を調整可能にする
3. **撮影設定のカスタマイズ**: 露出、フォーカス、ズーム倍率を調整可能にする
4. **設定の永続化**: UserDefaultsを使用してアプリ全体で共通の設定として保存

### Non-Goals

- カメラフィルター機能の追加
- 動画撮影機能
- 複数画像の同時撮影
- クラウド同期された設定

## User Stories

### US-1: OCR設定の調整

**As a** ユーザー
**I want to** OCRの認識精度と言語を設定できる
**So that** 様々な言語や画質の写真から正確にテキストを認識できる

**Acceptance Criteria**:
- [ ] 設定画面でOCR認識精度（accurate/fast）を選択できる
- [ ] 設定画面でOCR認識言語（ja-JP, en-USなど）を選択できる
- [ ] 設定画面で画像圧縮サイズ（KB単位）を調整できる
- [ ] 設定した内容がカメラ撮影時に反映される
- [ ] 設定はアプリ再起動後も保持される

### US-2: カメラUI設定

**As a** ユーザー
**I want to** カメラUIをカスタマイズできる
**So that** 使いやすいレイアウトで撮影できる

**Acceptance Criteria**:
- [ ] シャッターボタンの位置（中央/右/左）を選択できる
- [ ] フラッシュのON/OFF設定を保存できる
- [ ] グリッド表示のON/OFF設定を保存できる
- [ ] 設定した内容がカメラ起動時に反映される

### US-3: 撮影設定の調整

**As a** ユーザー
**I want to** 露出やフォーカスを手動で調整できる
**So that** 様々な撮影環境で最適な画像を撮影できる

**Acceptance Criteria**:
- [ ] 露出モード（自動/マニュアル）を選択できる
- [ ] フォーカスモード（自動/マニュアル）を選択できる
- [ ] ズーム倍率を調整できる
- [ ] マニュアルモードでは撮影時にリアルタイムで調整できる

### US-4: 開発時設定調整

**As a** 開発者
**I want to** コード内でカメラ設定を調整できる
**So that** 実装時に様々な設定パターンをテストできる

**Acceptance Criteria**:
- [ ] CameraSettings.defaultを変更することで設定を調整できる
- [ ] UserDefaultsに直接値を設定することで動作確認できる
- [ ] 設定変更後、アプリ再起動で反映される

## Functional Requirements

### FR-1: カメラ設定モデル

カメラ設定を表現するデータモデルを定義する。

**必須項目**:
- OCR認識レベル（accurate/fast）
- OCR認識言語（文字列配列）
- 画像圧縮サイズ（Double、KB単位）
- シャッターボタン位置（center/right/left）
- フラッシュ有効/無効（Bool）
- グリッド表示有効/無効（Bool）
- 露出モード（auto/manual）
- フォーカスモード（auto/manual）
- ズーム倍率（Double、1.0-5.0）

**制約**:
- Codable準拠（UserDefaults保存のため）
- Sendable準拠（Strict Concurrency対応のため）
- デフォルト値の定義

### FR-2: 設定の永続化

UserDefaultsを使用して設定を保存・読み込みする。

**機能**:
- 設定の保存
- 設定の読み込み（存在しない場合はデフォルト値を返す）
- 設定のリセット

### FR-3: カスタムカメラUI

AVFoundationを使用したカスタムカメラを実装する。

**機能**:
- カメラプレビュー表示
- 写真撮影
- カメラ切り替え（前面/背面）
- フラッシュ切り替え
- グリッド表示/非表示
- ズーム調整
- 露出調整（マニュアルモード時）
- フォーカス調整（マニュアルモード時）

**制約**:
- iOS 17+対応
- カメラ権限チェック
- シミュレータ非対応時の対応

### FR-4: OCR設定の適用

既存のOCR処理に設定を適用する。

**変更箇所**:
- `RecognizeTextLocalRequest`: 設定を受け取るメソッドを追加
- `UIImage+Extension`: 設定対応のリサイズメソッドを追加
- `SeedEditViewModel`: 設定を使用したOCR実行
- `CoordinatesEditViewModel`: 設定を使用したOCR実行

### FR-5: 開発時設定調整

開発時にコード内で設定を変更できる仕組みを提供する。

**方法**:
1. **デフォルト値の変更**: `CameraSettings.default`の定義を変更
2. **UserDefaults直接操作**: デバッグコードでUserDefaultsに設定を保存
3. **テストフィクスチャ**: テスト用の設定プリセットを用意

**例**:
```swift
// デフォルト値を変更（開発時）
extension CameraSettings {
    static let `default` = CameraSettings(
        ocrRecognitionLevel: .fast,  // 変更: 高速モードに
        ocrLanguages: ["en-US"],     // 変更: 英語に
        imageCompressionSizeKB: 500.0,
        // ...
    )
}

// または、アプリ起動時に設定を上書き（デバッグビルド時のみ）
#if DEBUG
Task {
    var settings = CameraSettings.default
    settings.gridEnabled = true
    try? await SaveCameraSettingsUseCaseImpl().execute(settings)
}
#endif
```

## Technical Requirements

### TR-1: アーキテクチャ

MVVM + Layered Architectureに従う。

**レイヤー構成**:
- Model層: `CameraSettings`
- Data層: `CameraSettingsRepository`
- Domain層: `GetCameraSettingsUseCase`, `SaveCameraSettingsUseCase`
- UI層: `CustomCameraView`, `CameraSettingsView`

### TR-2: 依存性注入

swift-dependenciesを使用してDIを実装する。

**DI対象**:
- `CameraSettingsRepository`
- `GetCameraSettingsUseCase`
- `SaveCameraSettingsUseCase`

### TR-3: テスト

Swift Testingを使用してテストを記述する。

**テスト対象**:
- `CameraSettingsRepository`: UserDefaultsの読み書き
- `GetCameraSettingsUseCase`: 設定取得ロジック
- `SaveCameraSettingsUseCase`: 設定保存ロジック
- `CameraSettingsViewModel`: 設定画面のロジック
- `CustomCameraViewModel`: カメラ制御ロジック

### TR-4: 後方互換性

既存のImagePickerを維持し、段階的に移行する。

**戦略**:
- 既存の`ImagePicker`は削除しない
- `ImagePickerAdapter`で新旧カメラを切り替え
- Phase 2で既存カメラにOCR設定を適用（クイックウィン）
- Phase 3でカスタムカメラを実装

## Non-Functional Requirements

### NFR-1: パフォーマンス

- カメラ起動時間: 1秒以内
- 設定読み込み時間: 100ms以内
- OCR処理時間: 既存と同等（設定変更による劣化なし）

### NFR-2: ユーザビリティ

- 設定画面は直感的で分かりやすいUI
- 設定項目には適切な説明を表示
- デフォルト値は一般的な用途に最適化

### NFR-3: 信頼性

- カメラ権限がない場合は適切なエラーメッセージを表示
- 不正な設定値の場合はデフォルト値を使用
- アプリクラッシュを引き起こさない

### NFR-4: 保守性

- コードはSwiftLint/SwiftFormatに準拠
- Strict Concurrency Checkingに対応
- 十分なコメントとドキュメント

## Success Criteria

1. ✅ すべてのUser Storiesが完了している
2. ✅ すべてのテストがパスしている
3. ✅ SwiftLint/SwiftFormatチェックがパスしている
4. ✅ Strict Concurrencyチェックでビルドが通る
5. ✅ 既存のSeedEditView、CoordinatesEditViewで正常に動作する
6. ✅ カメラ権限がない場合も適切に処理される
7. ✅ シミュレータでもビルドエラーが発生しない

## Out of Scope

以下は本機能の範囲外とする：

- カメラフィルター・エフェクト機能
- 動画撮影機能
- バーストモード・連写機能
- RAW画像撮影
- 手ぶれ補正設定
- カメラ設定のクラウド同期
- 画面ごとに異なる設定（すべて共通設定）

## Dependencies

### External Dependencies

- AVFoundation（カメラ制御）
- Vision Framework（OCR処理、既存）
- swift-dependencies（DI、既存）
- Swift Testing（テスト、既存）

### Internal Dependencies

- 既存のOCR実装（`RecognizeTextLocalRequest`）
- 既存のViewModel実装（`SeedEditViewModel`, `CoordinatesEditViewModel`）
- 既存の画像処理（`UIImage+Extension`）

## Risks and Mitigations

### Risk 1: AVFoundationの複雑性

**リスク**: AVFoundationの実装が複雑で、予想以上に時間がかかる

**緩和策**: Phase 2でクイックウィンを得て、Phase 3を慎重に実装

### Risk 2: 既存機能への影響

**リスク**: 既存のカメラ機能が動作しなくなる

**緩和策**: 段階的移行、既存コードの変更は最小限、十分なテスト

### Risk 3: デバイス互換性

**リスク**: シミュレータやカメラのないデバイスで問題が発生

**緩和策**: デバイス可用性チェック、実機テスト必須

### Risk 4: ユーザビリティ

**リスク**: 設定項目が多すぎてユーザーが混乱する

**緩和策**: 適切なデフォルト値、リセット機能、設定の説明

## Timeline

### Phase 1: 設定基盤の構築（1日）

- CameraSettingsモデル
- CameraSettingsRepository
- GetCameraSettingsUseCase
- SaveCameraSettingsUseCase
- テスト

### Phase 2: OCR設定の適用（1日）

- RecognizeTextLocalRequest拡張
- UIImage+Extension拡張
- 既存ViewModelの変更
- テスト

### Phase 3: カスタムカメラUI（2-3日）

- CameraPreviewView
- CustomCameraViewModel
- CameraControlsView
- CustomCameraView
- Info.plist更新
- テスト

### Phase 4: 統合とテスト（1日）

- ImagePickerAdapter
- 既存View更新
- 統合テスト
- コード品質チェック

**合計**: 5-6日（設定画面UI不要のため短縮）

## References

- [AVFoundation Camera Setup](https://developer.apple.com/documentation/avfoundation/capture_setup)
- [Vision Framework Text Recognition](https://developer.apple.com/documentation/vision/recognizing_text_in_images)
- [Swift Concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)
- プロジェクト憲章: `.specify/memory/constitution.md`
- 開発ガイド: `CLAUDE.md`
