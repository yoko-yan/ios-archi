# Quickstart: カメラ画面カスタマイズ機能

**Feature**: 001-camera-customization
**Date**: 2025-12-22
**Status**: Implementation Ready

## Overview

本ドキュメントは、カメラ画面カスタマイズ機能の開発セットアップ、実装手順、テスト方法をまとめたクイックスタートガイドです。

---

## Prerequisites

### 必要な環境

- **Xcode**: 15.0+
- **macOS**: 14.0+ (Sonoma)
- **iOS Deployment Target**: 17.0+
- **Swift**: 5.9+

### 必要な知識

- SwiftUI の基礎
- MVVM アーキテクチャ
- async/await (Swift Concurrency)
- AVFoundation の基本
- swift-dependencies の使い方
- Swift Testing の基本

---

## Setup

### 1. ブランチの確認

```bash
# 現在のブランチを確認
git branch

# 001-camera-customization ブランチにいることを確認
# もしいない場合は切り替え
git checkout 001-camera-customization
```

### 2. 依存関係の解決

```bash
# プロジェクトのセットアップ
make bootstrap

# または手動で
xcodebuild -resolvePackageDependencies -workspace ios-archi.xcworkspace -scheme ios-archi
```

### 3. プロジェクトを開く

```bash
open ios-archi.xcworkspace
```

---

## Implementation Order

実装は以下の順序で進めることを推奨します：

### Phase 1: 設定基盤の構築（優先度：最高）

1. **CameraSettings.swift** を作成
   - パス: `Package/Sources/AppFeature/Model/CameraSettings.swift`
   - 内容: [data-model.md](./data-model.md) の定義を参照

2. **CameraSettingsRepository.swift** を作成
   - パス: `Package/Sources/AppFeature/Data/Repository/CameraSettingsRepository.swift`
   - UserDefaults によるCRUD操作を実装

3. **GetCameraSettingsUseCase.swift** を作成
   - パス: `Package/Sources/AppFeature/Domain/GetCameraSettingsUseCase.swift`
   - Repository から設定を取得するロジック

4. **SaveCameraSettingsUseCase.swift** を作成
   - パス: `Package/Sources/AppFeature/Domain/SaveCameraSettingsUseCase.swift`
   - Repository へ設定を保存するロジック

5. **テストを作成**
   - `Package/Tests/AppFeatureTests/Data/CameraSettingsRepositoryTests.swift`
   - `Package/Tests/AppFeatureTests/Domain/GetCameraSettingsUseCaseTests.swift`
   - `Package/Tests/AppFeatureTests/Domain/SaveCameraSettingsUseCaseTests.swift`

6. **動作確認**
   ```bash
   # テスト実行
   xcodebuild test -workspace ios-archi.xcworkspace -scheme ios-archi -only-testing:AppFeatureTests/CameraSettingsRepositoryTests
   ```

### Phase 2: OCR設定の適用（クイックウィン）

1. **RecognizeTextLocalRequest.swift** を拡張
   - パス: `Package/Sources/AppFeature/Data/Request/Local/RecognizeTextLocalRequest.swift`
   - 設定を受け取るメソッドをオーバーロード追加

2. **UIImage+Extension.swift** を拡張
   - パス: `Package/Sources/AppFeature/Extension/UIImage+Extension.swift`
   - 設定対応のリサイズメソッド追加

3. **既存ViewModelを変更**
   - `Package/Sources/AppFeature/UI/SeedEdit/SeedEditViewModel.swift`
   - `Package/Sources/AppFeature/UI/CoordinatesEditView/CoordinatesEditViewModel.swift`
   - `@Dependency(\.getCameraSettingsUseCase)` を注入して設定を使用

4. **動作確認**
   - アプリをビルド・実行し、OCR機能が設定を反映しているか確認

### Phase 3: カスタムカメラUI実装

1. **CameraPreviewView.swift** を作成
   - パス: `Package/Sources/AppFeature/UI/Camera/CameraPreviewView.swift`
   - AVCaptureVideoPreviewLayer のラッパー

2. **CustomCameraUiState.swift** を作成
   - パス: `Package/Sources/AppFeature/UI/Camera/CustomCameraUiState.swift`
   - カメラ状態管理

3. **CustomCameraViewModel.swift** を作成
   - パス: `Package/Sources/AppFeature/UI/Camera/CustomCameraViewModel.swift`
   - AVCaptureSession 管理、撮影処理

4. **CameraControlsView.swift** を作成
   - パス: `Package/Sources/AppFeature/UI/Camera/CameraControlsView.swift`
   - シャッター、フラッシュ、グリッド等のUI

5. **CustomCameraView.swift** を作成
   - パス: `Package/Sources/AppFeature/UI/Camera/CustomCameraView.swift`
   - メイン統合View

6. **Info.plist を更新**
   - パス: `App/ios-archi/Info.plist`
   - `NSCameraUsageDescription` を追加

7. **テストを作成**
   - `Package/Tests/AppFeatureTests/UI/CustomCameraViewModelTests.swift`

8. **動作確認**
   - 実機でカメラUIが正常に動作するか確認

### Phase 4: 統合とテスト

1. **ImagePickerAdapter.swift** を作成
   - パス: `Package/Sources/AppFeature/UI/Common/ImagePickerAdapter.swift`
   - 新旧カメラの切り替えロジック

2. **既存Viewを更新**
   - `SeedEditView.swift`: ImagePicker → ImagePickerAdapter
   - `CoordinatesEditView.swift`: ImagePicker → ImagePickerAdapter

3. **統合テスト実施**
   ```bash
   # すべてのテストを実行
   xcodebuild test -workspace ios-archi.xcworkspace -scheme ios-archi
   ```

4. **コード品質チェック**
   ```bash
   # SwiftLint
   make lint

   # SwiftFormat
   make format

   # ビルド確認
   xcodebuild build -workspace ios-archi.xcworkspace -scheme ios-archi
   ```

---

## Usage Examples

### 設定の取得と保存

```swift
import Dependencies

// ViewModel内での使用例
@MainActor
@Observable
final class ExampleViewModel {
    @ObservationIgnored
    @Dependency(\.getCameraSettingsUseCase) private var getCameraSettings
    @ObservationIgnored
    @Dependency(\.saveCameraSettingsUseCase) private var saveCameraSettings

    func loadSettings() async {
        do {
            let settings = try await getCameraSettings.execute()
            // 設定を使用
        } catch {
            print("設定の読み込みに失敗: \(error)")
        }
    }

    func saveSettings(_ settings: CameraSettings) async {
        do {
            try await saveCameraSettings.execute(settings)
        } catch {
            print("設定の保存に失敗: \(error)")
        }
    }
}
```

### 設定の調整（開発時）

```swift
// 方法1: CameraSettings.defaultを変更
extension CameraSettings {
    static let `default` = CameraSettings(
        ocrRecognitionLevel: .fast,  // 変更: 高速モードに
        ocrLanguages: ["en-US"],     // 変更: 英語に
        imageCompressionSizeKB: 500.0,
        shutterButtonPosition: .right,
        flashEnabled: true,
        gridEnabled: true,
        exposureMode: .manual,
        focusMode: .manual,
        zoomFactor: 2.0
    )
}

// 方法2: デバッグビルド時に設定を上書き
#if DEBUG
// AppDelegate や App の init() などで実行
Task {
    var settings = CameraSettings.default
    settings.gridEnabled = true
    settings.flashEnabled = false
    try? await SaveCameraSettingsUseCaseImpl().execute(settings)
}
#endif
```

### カメラViewの表示

```swift
import SwiftUI

struct ExampleView: View {
    @State private var showCamera = false
    @State private var capturedImage: UIImage?

    var body: some View {
        Button("カメラを開く") {
            showCamera = true
        }
        .sheet(isPresented: $showCamera) {
            CustomCameraView(
                capturedImage: $capturedImage,
                show: $showCamera
            )
        }
    }
}
```

### OCR実行（設定適用）

```swift
func performOCR(image: UIImage) async {
    do {
        // 設定を取得
        let settings = try await getCameraSettings.execute()

        // 画像をリサイズ（設定を使用）
        let resizedImage = image
            .normalizedImage()?
            .resized(withSettings: settings)

        guard let resizedImage else { return }

        // OCR実行（設定を使用）
        let texts = try await RecognizeTextLocalRequest()
            .perform(image: resizedImage, settings: settings)

        // 結果を処理
        print("認識されたテキスト: \(texts)")
    } catch {
        print("OCR処理に失敗: \(error)")
    }
}
```

---

## Testing

### テストの実行

```bash
# すべてのテストを実行
xcodebuild test -workspace ios-archi.xcworkspace -scheme ios-archi

# 特定のテストスイートのみ実行
xcodebuild test -workspace ios-archi.xcworkspace -scheme ios-archi \
  -only-testing:AppFeatureTests/CameraSettingsRepositoryTests

# 特定のテストケースのみ実行
xcodebuild test -workspace ios-archi.xcworkspace -scheme ios-archi \
  -only-testing:AppFeatureTests/CameraSettingsRepositoryTests/testSaveAndLoad
```

### テストの記述例（Swift Testing）

```swift
import Testing
import Dependencies
@testable import AppFeature

@Suite("CameraSettings Repository Tests")
struct CameraSettingsRepositoryTests {

    @Test("デフォルト設定を返す")
    func testDefaultSettings() async throws {
        let repository = CameraSettingsRepositoryImpl()
        let settings = try await repository.get()

        #expect(settings == CameraSettings.default)
    }

    @Test("設定を保存して読み込める")
    func testSaveAndLoad() async throws {
        let repository = CameraSettingsRepositoryImpl()
        var settings = CameraSettings.default
        settings.flashEnabled = true
        settings.gridEnabled = true

        try await repository.save(settings)
        let loaded = try await repository.get()

        #expect(loaded.flashEnabled == true)
        #expect(loaded.gridEnabled == true)
    }
}
```

---

## Debugging

### カメラ権限の確認

```swift
// カメラ権限の状態をログ出力
let status = AVCaptureDevice.authorizationStatus(for: .video)
print("カメラ権限ステータス: \(status)")
```

### UserDefaults の確認

```bash
# シミュレータのUserDefaultsを確認
xcrun simctl get_app_container booted com.yourapp.ios data

# または実機でLLDBで確認
(lldb) po UserDefaults.standard.dictionaryRepresentation()
```

### AVFoundation セッションのログ

```swift
// セッション開始時のログ
captureSession.beginConfiguration()
print("カメラセッション設定開始")
// ...
captureSession.commitConfiguration()
print("カメラセッション設定完了")
```

---

## Troubleshooting

### 問題: カメラが起動しない

**原因**: カメラ権限が許可されていない

**解決策**:
1. Info.plistに`NSCameraUsageDescription`が追加されているか確認
2. Settings.app > Privacy > Camera でアプリの権限を確認
3. アプリを再インストールして権限リクエストをやり直す

### 問題: ビルドエラー "Sendable protocol requirement not satisfied"

**原因**: Strict Concurrency Checkingに対応していない型を使用

**解決策**:
1. 該当の型に`Sendable`プロトコルを追加
2. `@MainActor`や`@Sendable`を適切に使用
3. `nonisolated`キーワードを使用

### 問題: テストが失敗する

**原因**: swift-dependenciesのモックが正しく設定されていない

**解決策**:
```swift
await withDependencies {
    $0.cameraSettingsRepository = MockCameraSettingsRepository()
} operation: {
    // テストコード
}
```

---

## Performance Optimization

### カメラ起動の高速化

```swift
// カメラセッションを事前に準備
func prepareCamera() async {
    sessionQueue.async { [weak self] in
        self?.captureSession.startRunning()
    }
}
```

### 設定読み込みのキャッシング

```swift
// ViewModelで設定をキャッシュ
private var cachedSettings: CameraSettings?

func getSettings() async throws -> CameraSettings {
    if let cached = cachedSettings {
        return cached
    }
    let settings = try await getCameraSettings.execute()
    cachedSettings = settings
    return settings
}
```

---

## Next Steps

実装完了後：

1. **コードレビュー**: すべてのコードがコーディング規約に準拠しているか確認
2. **ドキュメント更新**: `CLAUDE.md` にカメラ機能の説明を追加
3. **プルリクエスト作成**: `/speckit.taskstoissues` でGitHub Issuesを作成（オプション）
4. **実機テスト**: 複数のiOSデバイスで動作確認
5. **パフォーマンステスト**: Instrumentsでメモリリーク、パフォーマンスを確認

---

## References

- [Feature Specification](./spec.md)
- [Implementation Plan](./plan.md)
- [Research Document](./research.md)
- [Data Model](./data-model.md)
- [Project Constitution](../../.specify/memory/constitution.md)
- [Development Guide](../../CLAUDE.md)

---

## Support

質問や問題がある場合:

1. [CLAUDE.md](../../CLAUDE.md) の開発ガイドを参照
2. [spec.md](./spec.md) の要件を再確認
3. [research.md](./research.md) の技術調査結果を参照
4. プロジェクトの他の実装例を参考にする

**Happy Coding!** 🚀
