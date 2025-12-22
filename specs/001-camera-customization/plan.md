# Implementation Plan: カメラ画面カスタマイズ機能

**Branch**: `001-camera-customization` | **Date**: 2025-12-22 | **Spec**: [spec.md](./spec.md)

## Summary

カメラ画面のカスタマイズ機能を追加し、OCR設定（認識精度、言語、画像圧縮）、カメラUI（ボタン配置、フラッシュ、グリッド）、撮影設定（露出、フォーカス、ズーム）をカスタマイズ可能にする。設定はUserDefaultsで保存し、開発時にコード内で調整できる。UIImagePickerControllerからAVFoundationカスタムカメラへ段階的に移行する。

**注**: ユーザー向け設定画面UIは不要。開発時にCameraSettings.defaultを変更することで設定調整を行う。

## Technical Context

- **Language/Version**: Swift 5.9+
- **Primary Dependencies**: AVFoundation, Vision Framework, swift-dependencies, SwiftUI
- **Storage**: UserDefaults（設定永続化）
- **Testing**: Swift Testing（@Test, @Suite, #expect）
- **Target Platform**: iOS 17+
- **Project Type**: mobile（SPMマルチモジュール）
- **Performance Goals**: カメラ起動 <1秒, 設定読み込み <100ms, UI操作 60fps
- **Constraints**: メインスレッドブロック禁止, Strict Concurrency準拠, カメラ権限必須
- **Scale/Scope**: 約12-15新規ファイル, 5既存ファイル変更

## Constitution Check

**Status**: ✅ PASS

すべての憲章要件を満たしています：
- SwiftLint/SwiftFormat準拠
- Strict Concurrency対応
- Swift Testing使用
- MVVM + Layered Architecture
- async/await使用

## Project Structure

### Source Code

```text
Package/Sources/AppFeature/
├── Model/
│   └── CameraSettings.swift                      # 新規
├── Data/
│   ├── Repository/
│   │   └── CameraSettingsRepository.swift        # 新規
│   └── Request/Local/
│       └── RecognizeTextLocalRequest.swift       # 変更
├── Domain/
│   ├── GetCameraSettingsUseCase.swift            # 新規
│   └── SaveCameraSettingsUseCase.swift           # 新規
├── UI/
│   ├── Camera/
│   │   ├── CustomCameraView.swift                # 新規
│   │   ├── CustomCameraViewModel.swift           # 新規
│   │   ├── CustomCameraUiState.swift             # 新規
│   │   ├── CameraPreviewView.swift               # 新規
│   │   └── CameraControlsView.swift              # 新規
│   ├── Common/
│   │   ├── ImagePicker.swift                     # 既存
│   │   └── ImagePickerAdapter.swift              # 新規
│   ├── SeedEdit/
│   │   ├── SeedEditView.swift                    # 変更
│   │   └── SeedEditViewModel.swift               # 変更
│   └── CoordinatesEditView/
│       ├── CoordinatesEditView.swift             # 変更
│       └── CoordinatesEditViewModel.swift        # 変更
└── Extension/
    └── UIImage+Extension.swift                   # 変更

Package/Tests/AppFeatureTests/
├── Data/
│   └── CameraSettingsRepositoryTests.swift       # 新規
├── Domain/
│   ├── GetCameraSettingsUseCaseTests.swift       # 新規
│   └── SaveCameraSettingsUseCaseTests.swift      # 新規
└── UI/
    └── CustomCameraViewModelTests.swift          # 新規

App/ios-archi/
└── Info.plist                                    # 変更
```

## Implementation Phases

### Phase 1: 設定基盤の構築

**目標**: 設定モデル、Repository、UseCaseの実装

1. CameraSettings.swift - データモデル定義
2. CameraSettingsRepository.swift - UserDefaults永続化
3. GetCameraSettingsUseCase.swift - 設定取得
4. SaveCameraSettingsUseCase.swift - 設定保存
5. テスト作成

**成果物**: 設定の保存・読み込みが動作する基盤

### Phase 2: OCR設定の適用

**目標**: 既存カメラでOCR設定を利用可能に（クイックウィン）

1. RecognizeTextLocalRequest.swift拡張 - 設定対応メソッド追加
2. UIImage+Extension.swift拡張 - 設定対応リサイズメソッド
3. SeedEditViewModel.swift変更 - 設定を使用したOCR
4. CoordinatesEditViewModel.swift変更 - 同上

**成果物**: 既存カメラでOCR設定が反映される

### Phase 3: カスタムカメラUI

**目標**: AVFoundationベースのカスタムカメラ

1. CameraPreviewView.swift - AVFoundationプレビュー
2. CustomCameraUiState.swift - 状態管理
3. CustomCameraViewModel.swift - カメラセッション管理
4. CameraControlsView.swift - コントロールUI
5. CustomCameraView.swift - メイン統合View
6. Info.plist更新 - カメラ権限追加
7. テスト作成

**成果物**: フル機能カスタムカメラView

### Phase 4: 統合とテスト

**目標**: 新旧カメラ切り替えと全体テスト

1. ImagePickerAdapter.swift - 新旧カメラ切り替え
2. SeedEditView.swift更新 - Adapter使用
3. CoordinatesEditView.swift更新 - Adapter使用
4. 統合テスト実施
5. コード品質チェック

**成果物**: 完全統合されたカメラ機能

## Key Design Decisions

### 設定調整方法（ユーザーUI不要）

開発時にコード内で設定を調整：

```swift
// 方法1: デフォルト値を変更
extension CameraSettings {
    static let `default` = CameraSettings(
        ocrRecognitionLevel: .fast,  // 変更
        ocrLanguages: ["en-US"],     // 変更
        // ...
    )
}

// 方法2: デバッグビルドで上書き
#if DEBUG
Task {
    var settings = CameraSettings.default
    settings.gridEnabled = true
    try? await saveCameraSettings.execute(settings)
}
#endif
```

### DI設計（swift-dependencies）

```swift
// Repository
extension DependencyValues {
    var cameraSettingsRepository: any CameraSettingsRepository {
        get { self[CameraSettingsRepositoryKey.self] }
        set { self[CameraSettingsRepositoryKey.self] = newValue }
    }
}

// UseCase
extension DependencyValues {
    var getCameraSettingsUseCase: any GetCameraSettingsUseCase {
        get { self[GetCameraSettingsUseCaseKey.self] }
        set { self[GetCameraSettingsUseCaseKey.self] = newValue }
    }
}

// ViewModelで使用
@MainActor
@Observable
final class SeedEditViewModel {
    @ObservationIgnored
    @Dependency(\.getCameraSettingsUseCase) private var getCameraSettings
}
```

## Success Criteria

- [ ] カメラ設定の保存・読み込みが動作
- [ ] OCR設定（精度、言語、圧縮）が反映
- [ ] カスタムカメラUI（ボタン位置、フラッシュ、グリッド）が動作
- [ ] 撮影設定（露出、フォーカス、ズーム）が動作
- [ ] 既存のSeedEditView、CoordinatesEditViewで正常動作
- [ ] すべてのテストがパス
- [ ] SwiftLint/SwiftFormatチェックがパス
- [ ] カメラ権限が適切に処理される

## References

- [Feature Specification](./spec.md)
- [Research Document](./research.md)
- [Data Model](./data-model.md)
- [Quickstart Guide](./quickstart.md)
- [Project Constitution](../../.specify/memory/constitution.md)

## Next Steps

1. `/speckit.tasks` でtasks.md生成
2. Phase 1実装開始
3. 各Phase完了後にテスト実行
4. 定期的なコミット
