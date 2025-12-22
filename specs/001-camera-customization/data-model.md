# Data Model: カメラ画面カスタマイズ機能

**Feature**: 001-camera-customization
**Date**: 2025-12-22
**Status**: Design Phase

## Overview

本文書は、カメラ画面カスタマイズ機能で使用するデータモデルを定義します。

## Entities

### 1. CameraSettings

カメラの設定情報を表現するデータモデル。

#### Properties

| Property | Type | Description | Constraints | Default Value |
|----------|------|-------------|-------------|---------------|
| `ocrRecognitionLevel` | `OCRRecognitionLevel` | OCR認識精度 | `.accurate` or `.fast` | `.accurate` |
| `ocrLanguages` | `[String]` | OCR認識言語（言語コード配列） | 非空配列 | `["ja-JP"]` |
| `imageCompressionSizeKB` | `Double` | 画像圧縮サイズ（KB） | `>0` | `1000.0` |
| `shutterButtonPosition` | `ShutterButtonPosition` | シャッターボタン位置 | `.center` / `.right` / `.left` | `.center` |
| `flashEnabled` | `Bool` | フラッシュ有効/無効 | - | `false` |
| `gridEnabled` | `Bool` | グリッド表示有効/無効 | - | `false` |
| `exposureMode` | `ExposureMode` | 露出モード | `.auto` or `.manual` | `.auto` |
| `focusMode` | `FocusMode` | フォーカスモード | `.auto` or `.manual` | `.auto` |
| `zoomFactor` | `Double` | ズーム倍率 | `1.0 ... 5.0` | `1.0` |

#### Enums

##### OCRRecognitionLevel

```swift
enum OCRRecognitionLevel: String, Codable, CaseIterable, Sendable {
    case accurate  // 高精度（処理時間長）
    case fast      // 高速（精度やや低）

    var vnLevel: VNRequestTextRecognitionLevel {
        switch self {
        case .accurate: return .accurate
        case .fast: return .fast
        }
    }

    var displayName: String {
        switch self {
        case .accurate: return "高精度"
        case .fast: return "高速"
        }
    }
}
```

##### ShutterButtonPosition

```swift
enum ShutterButtonPosition: String, Codable, CaseIterable, Sendable {
    case center  // 中央
    case right   // 右
    case left    // 左

    var displayName: String {
        switch self {
        case .center: return "中央"
        case .right: return "右"
        case .left: return "左"
        }
    }
}
```

##### ExposureMode

```swift
enum ExposureMode: String, Codable, CaseIterable, Sendable {
    case auto    // 自動露出
    case manual  // マニュアル露出

    var displayName: String {
        switch self {
        case .auto: return "自動"
        case .manual: return "マニュアル"
        }
    }
}
```

##### FocusMode

```swift
enum FocusMode: String, Codable, CaseIterable, Sendable {
    case auto    // オートフォーカス
    case manual  // マニュアルフォーカス

    var displayName: String {
        switch self {
        case .auto: return "自動"
        case .manual: return "マニュアル"
        }
    }
}
```

#### Protocol Conformance

- **Codable**: UserDefaultsへのJSON保存のため
- **Equatable**: 値の比較、変更検知のため
- **Sendable**: Strict Concurrency対応、スレッド間で安全に共有するため

#### Validation Rules

```swift
extension CameraSettings {
    /// 設定値が有効かをバリデーション
    func validate() -> ValidationResult {
        var errors: [ValidationError] = []

        // OCR言語が空でないこと
        if ocrLanguages.isEmpty {
            errors.append(.emptyLanguages)
        }

        // 画像圧縮サイズが正の値であること
        if imageCompressionSizeKB <= 0 {
            errors.append(.invalidCompressionSize)
        }

        // ズーム倍率が範囲内であること
        if zoomFactor < 1.0 || zoomFactor > 5.0 {
            errors.append(.invalidZoomFactor)
        }

        return errors.isEmpty ? .valid : .invalid(errors)
    }

    enum ValidationError: Error {
        case emptyLanguages
        case invalidCompressionSize
        case invalidZoomFactor
    }

    enum ValidationResult {
        case valid
        case invalid([ValidationError])
    }
}
```

#### Default Factory

```swift
extension CameraSettings {
    /// デフォルト設定
    static let `default` = CameraSettings(
        ocrRecognitionLevel: .accurate,
        ocrLanguages: ["ja-JP"],
        imageCompressionSizeKB: 1000.0,
        shutterButtonPosition: .center,
        flashEnabled: false,
        gridEnabled: false,
        exposureMode: .auto,
        focusMode: .auto,
        zoomFactor: 1.0
    )
}
```

#### Full Definition

```swift
import Foundation
import Vision

/// カメラ設定モデル
struct CameraSettings: Codable, Equatable, Sendable {
    // MARK: - OCR設定

    /// OCR認識精度レベル
    var ocrRecognitionLevel: OCRRecognitionLevel

    /// OCR認識言語（言語コード配列、例: ["ja-JP", "en-US"]）
    var ocrLanguages: [String]

    /// 画像圧縮サイズ（KB単位）
    var imageCompressionSizeKB: Double

    // MARK: - カメラUI設定

    /// シャッターボタンの位置
    var shutterButtonPosition: ShutterButtonPosition

    /// フラッシュ有効/無効
    var flashEnabled: Bool

    /// グリッド表示有効/無効
    var gridEnabled: Bool

    // MARK: - 撮影設定

    /// 露出モード
    var exposureMode: ExposureMode

    /// フォーカスモード
    var focusMode: FocusMode

    /// ズーム倍率（1.0〜5.0）
    var zoomFactor: Double

    // MARK: - Nested Types

    /// OCR認識精度レベル
    enum OCRRecognitionLevel: String, Codable, CaseIterable, Sendable {
        case accurate
        case fast

        var vnLevel: VNRequestTextRecognitionLevel {
            switch self {
            case .accurate: return .accurate
            case .fast: return .fast
            }
        }

        var displayName: String {
            switch self {
            case .accurate: return "高精度"
            case .fast: return "高速"
            }
        }
    }

    /// シャッターボタン位置
    enum ShutterButtonPosition: String, Codable, CaseIterable, Sendable {
        case center
        case right
        case left

        var displayName: String {
            switch self {
            case .center: return "中央"
            case .right: return "右"
            case .left: return "左"
            }
        }
    }

    /// 露出モード
    enum ExposureMode: String, Codable, CaseIterable, Sendable {
        case auto
        case manual

        var displayName: String {
            switch self {
            case .auto: return "自動"
            case .manual: return "マニュアル"
            }
        }
    }

    /// フォーカスモード
    enum FocusMode: String, Codable, CaseIterable, Sendable {
        case auto
        case manual

        var displayName: String {
            switch self {
            case .auto: return "自動"
            case .manual: return "マニュアル"
            }
        }
    }

    // MARK: - Factory

    /// デフォルト設定
    static let `default` = CameraSettings(
        ocrRecognitionLevel: .accurate,
        ocrLanguages: ["ja-JP"],
        imageCompressionSizeKB: 1000.0,
        shutterButtonPosition: .center,
        flashEnabled: false,
        gridEnabled: false,
        exposureMode: .auto,
        focusMode: .auto,
        zoomFactor: 1.0
    )
}
```

---

## State Models

### 2. CustomCameraUiState

カメラ画面のUI状態を管理するモデル。

#### Properties

| Property | Type | Description | Default Value |
|----------|------|-------------|---------------|
| `capturedImage` | `UIImage?` | 撮影された画像 | `nil` |
| `isSessionRunning` | `Bool` | カメラセッションが実行中か | `false` |
| `flashEnabled` | `Bool` | 現在のフラッシュ状態 | `false` |
| `gridEnabled` | `Bool` | 現在のグリッド表示状態 | `false` |
| `shutterButtonPosition` | `ShutterButtonPosition` | シャッターボタン位置 | `.center` |
| `zoomFactor` | `Double` | 現在のズーム倍率 | `1.0` |
| `cameraPosition` | `CameraPosition` | 現在のカメラ位置 | `.back` |
| `error` | `CameraError?` | エラー情報 | `nil` |

#### Definition

```swift
import UIKit

struct CustomCameraUiState: Equatable, Sendable {
    var capturedImage: UIImage?
    var isSessionRunning: Bool = false
    var flashEnabled: Bool = false
    var gridEnabled: Bool = false
    var shutterButtonPosition: CameraSettings.ShutterButtonPosition = .center
    var zoomFactor: Double = 1.0
    var cameraPosition: CameraPosition = .back
    var error: CameraError?

    enum CameraPosition: Sendable {
        case front
        case back
    }

    enum CameraError: Error, Sendable {
        case permissionDenied
        case deviceUnavailable
        case sessionConfigurationFailed
        case captureFailed
    }
}
```

---

## Relationships

```
CameraSettings (永続化データ)
    ↓
CameraSettingsRepository
    ↓
GetCameraSettingsUseCase / SaveCameraSettingsUseCase
    ↓
CustomCameraViewModel
    ↓
CustomCameraUiState
    ↓
CustomCameraView (SwiftUI)
```

**データフロー**:
1. アプリ起動時、CameraSettingsRepositoryがUserDefaultsから設定を読み込み
2. ViewModelがUseCaseを通じて設定を取得
3. ViewModelがUiStateを更新（設定から初期値を反映）
4. ViewがUiStateを監視して UI を描画
5. 開発時の設定変更は、CameraSettings.defaultを変更するか、デバッグコードでSaveUseCaseを実行

---

## Storage Format

### UserDefaults Key

```
Key: "camera_settings"
Format: JSON (via JSONEncoder/JSONDecoder)
```

### Example JSON

```json
{
  "ocrRecognitionLevel": "accurate",
  "ocrLanguages": ["ja-JP", "en-US"],
  "imageCompressionSizeKB": 1000.0,
  "shutterButtonPosition": "center",
  "flashEnabled": false,
  "gridEnabled": true,
  "exposureMode": "auto",
  "focusMode": "auto",
  "zoomFactor": 1.5
}
```

---

## Testing Strategy

### Unit Tests

- **CameraSettings validation**: バリデーションルールのテスト
- **CameraSettings serialization**: Codableのシリアライズ/デシリアライズテスト
- **CameraSettingsRepository**: UserDefaults保存/読み込みのテスト

### Test Fixtures

```swift
extension CameraSettings {
    static let testAccurate = CameraSettings(
        ocrRecognitionLevel: .accurate,
        ocrLanguages: ["ja-JP"],
        imageCompressionSizeKB: 1000.0,
        shutterButtonPosition: .center,
        flashEnabled: false,
        gridEnabled: false,
        exposureMode: .auto,
        focusMode: .auto,
        zoomFactor: 1.0
    )

    static let testFast = CameraSettings(
        ocrRecognitionLevel: .fast,
        ocrLanguages: ["en-US"],
        imageCompressionSizeKB: 500.0,
        shutterButtonPosition: .right,
        flashEnabled: true,
        gridEnabled: true,
        exposureMode: .manual,
        focusMode: .manual,
        zoomFactor: 2.0
    )
}
```

---

## Migration Strategy

将来的な設定項目の追加に対応するため、Codableのデフォルト値を活用：

```swift
struct CameraSettings: Codable, Equatable, Sendable {
    // 既存フィールド
    var ocrRecognitionLevel: OCRRecognitionLevel

    // 新規フィールド（デフォルト値付き）
    var newFeature: Bool = false

    // Codableは、JSONに存在しないフィールドにデフォルト値を使用
}
```

これにより、古いバージョンの設定JSONを読み込んでも、新しいフィールドは自動的にデフォルト値が設定される。

---

## Summary

- **CameraSettings**: カメラ設定の永続化データモデル（Codable, Equatable, Sendable）
- **CustomCameraUiState**: カメラ画面のUI状態モデル
- **Storage**: UserDefaults + JSON形式で保存
- **Validation**: 設定値のバリデーションルール定義
- **Testing**: ユニットテストとテストフィクスチャ
- **設定調整**: 開発時にCameraSettings.defaultを変更することで設定を調整（ユーザー向け設定UIは不要）

これらのデータモデルに基づき、Repository、UseCase、ViewModelを実装します。
