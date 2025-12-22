# Research: カメラ画面カスタマイズ機能

**Feature**: 001-camera-customization
**Date**: 2025-12-22
**Status**: Complete

## Overview

本文書は、カメラ画面カスタマイズ機能の実装に必要な技術調査の結果をまとめたものです。

## Research Topics

### 1. AVFoundation カメラ実装

#### Decision

AVFoundationを使用したカスタムカメラの実装には、`AVCaptureSession`を中核とした以下のコンポーネントを使用する：

- **AVCaptureSession**: カメラセッションの管理
- **AVCaptureDevice**: カメラデバイス（前面/背面）の管理
- **AVCaptureDeviceInput**: デバイス入力
- **AVCapturePhotoOutput**: 写真出力
- **AVCaptureVideoPreviewLayer**: プレビュー表示

**実装パターン**:
```swift
@MainActor
@Observable
final class CustomCameraViewModel {
    let captureSession = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private let sessionQueue = DispatchQueue(label: "camera.session")

    func setupCamera() async {
        // 権限チェック
        guard await checkCameraPermission() else { return }

        sessionQueue.async { [weak self] in
            guard let self else { return }
            // セッション設定
            self.captureSession.beginConfiguration()
            // デバイス入力追加
            // 写真出力追加
            self.captureSession.commitConfiguration()
        }
    }
}
```

#### Rationale

- **UIImagePickerController vs AVFoundation**: UIImagePickerControllerは簡易だがカスタマイズ性が低い。AVFoundationは完全な制御が可能で、露出・フォーカス・ズームなどの細かい調整ができる
- **専用DispatchQueue**: カメラセッションの操作は重い処理のため、メインスレッドをブロックしないよう専用キューで実行
- **async/await統合**: Swift Concurrencyと統合し、権限チェックや非同期処理を適切に管理

#### Alternatives Considered

1. **CameraUI Framework（iOS 17+）**: よりシンプルだが、カスタマイズ性がAVFoundationより低い。今回の要件（細かい設定調整）には不十分
2. **サードパーティライブラリ（ImagePicker、BSImagePicker）**: 依存関係を増やさず、学習目的のため自前実装を選択

#### References

- [Apple Developer: AVFoundation Camera Setup](https://developer.apple.com/documentation/avfoundation/capture_setup)
- [Apple Developer: AVCaptureSession](https://developer.apple.com/documentation/avfoundation/avcapturesession)
- [Human Interface Guidelines: Camera](https://developer.apple.com/design/human-interface-guidelines/camera)

---

### 2. Swift Testing フレームワーク

#### Decision

Quick/NimbleからSwift Testingへ完全移行する。テストは以下のパターンで記述する：

**基本パターン**:
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

        #expect(settings.ocrRecognitionLevel == .accurate)
        #expect(settings.ocrLanguages == ["ja-JP"])
        #expect(settings.imageCompressionSizeKB == 1000.0)
    }

    @Test("設定を保存して読み込める")
    func testSaveAndLoad() async throws {
        let repository = CameraSettingsRepositoryImpl()
        var settings = CameraSettings.default
        settings.flashEnabled = true

        try await repository.save(settings)
        let loaded = try await repository.get()

        #expect(loaded.flashEnabled == true)
    }
}
```

**依存性注入パターン**:
```swift
@Test("UseCase: 設定を取得できる")
func testGetSettings() async throws {
    await withDependencies {
        $0.cameraSettingsRepository = MockCameraSettingsRepository()
    } operation: {
        let useCase = GetCameraSettingsUseCaseImpl()
        let settings = try await useCase.execute()
        #expect(settings != nil)
    }
}
```

#### Rationale

- **Swift Testing優位性**:
  - Apple公式フレームワークで、Swift言語との統合が深い
  - `@Test`, `@Suite`マクロによる宣言的なテスト定義
  - `#expect`マクロによる型安全なアサーション
  - パラメータ化テストのサポート
  - 非同期テストのネイティブサポート

- **憲章準拠**: 憲章v1.1.0でSwift Testingが標準として定義されている

- **移行の影響**:
  - Quick/Nimbleは`describe/context/it`による BDD スタイル
  - Swift Testingは`@Suite/@Test`によるより Swift らしいスタイル
  - 既存のテストは段階的に移行可能

#### Alternatives Considered

1. **Quick/Nimbleを継続**: 既存テストとの一貫性は保てるが、憲章v1.1.0に違反する
2. **XCTest**: Apple標準だがSwift Testingより表現力が低い

#### Migration Notes

既存のプロジェクトにはQuick/Nimbleを使用したテストが存在する可能性があるが、**本機能の新規テストはすべてSwift Testingで記述する**。既存テストの移行は別タスクとして扱う。

#### References

- [Apple Developer: Swift Testing](https://developer.apple.com/documentation/testing)
- [Swift Evolution: SE-0415 Swift Testing](https://github.com/apple/swift-evolution/blob/main/proposals/0415-swift-testing.md)
- [Migration Guide: Quick/Nimble to Swift Testing](https://www.swift.org/blog/ready-set-test/)

---

### 3. UserDefaults 設定永続化

#### Decision

CameraSettingsをCodableにし、JSONエンコードしてUserDefaultsに保存する。

**実装パターン**:
```swift
protocol CameraSettingsRepository: Sendable {
    func get() async throws -> CameraSettings
    func save(_ settings: CameraSettings) async throws
    func reset() async throws
}

struct CameraSettingsRepositoryImpl: CameraSettingsRepository {
    private let userDefaults: UserDefaults
    private let key = "camera_settings"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func get() async throws -> CameraSettings {
        guard let data = userDefaults.data(forKey: key),
              let settings = try? JSONDecoder().decode(CameraSettings.self, from: data) else {
            return .default
        }
        return settings
    }

    func save(_ settings: CameraSettings) async throws {
        let data = try JSONEncoder().encode(settings)
        userDefaults.set(data, forKey: key)
    }

    func reset() async throws {
        userDefaults.removeObject(forKey: key)
    }
}
```

#### Rationale

- **UserDefaults選択理由**:
  - 設定データは小さい（数KB）ため、UserDefaultsで十分
  - CoreDataやファイルシステムよりもシンプル
  - 同期的アクセスが可能で高速
  - iCloudキーチェーン同期も将来的に可能（NSUbiquitousKeyValueStore）

- **JSON Encoding**:
  - Codableプロトコルで型安全性を保証
  - バージョニングが容易（新しいフィールドの追加に対応）
  - デバッグが容易（プレーンテキストで確認可能）

- **Repository Pattern**:
  - データソースを抽象化し、テストが容易
  - 将来的にCoreDataやファイルに移行しやすい
  - swift-dependenciesでモック化が容易

#### Alternatives Considered

1. **PropertyListEncoder**: JSONEncoderとほぼ同等だが、JSON形式の方が汎用性が高い
2. **CoreData**: オーバースペック。設定データは単純な構造体で十分
3. **FileManager + JSON file**: UserDefaultsより複雑で、ファイルI/Oのオーバーヘッドがある
4. **@AppStorage**: SwiftUIのプロパティラッパーだが、複雑な構造体のシリアライズには向かない

#### Performance Considerations

- **読み込み頻度**: カメラ起動時、設定画面表示時のみ。頻度は低い
- **書き込み頻度**: 設定変更時のみ。頻度は非常に低い
- **データサイズ**: 約500バイト程度の小さなデータ
- **キャッシング**: ViewModelで一度読み込んだ設定をメモリにキャッシュ可能

#### References

- [Apple Developer: UserDefaults](https://developer.apple.com/documentation/foundation/userdefaults)
- [Apple Developer: Codable](https://developer.apple.com/documentation/swift/codable)

---

### 4. カメラ権限管理

#### Decision

AVCaptureDeviceを使用したカメラ権限チェックとリクエストを実装する。

**実装パターン**:
```swift
func checkCameraPermission() async -> Bool {
    switch AVCaptureDevice.authorizationStatus(for: .video) {
    case .authorized:
        return true
    case .notDetermined:
        return await AVCaptureDevice.requestAccess(for: .video)
    case .denied, .restricted:
        return false
    @unknown default:
        return false
    }
}
```

**Info.plist設定**:
```xml
<key>NSCameraUsageDescription</key>
<string>写真からテキストを認識するためにカメラを使用します</string>
```

#### Rationale

- **async/await対応**: `requestAccess(for:)`はクロージャベースだが、Swift Concurrencyラッパーを使用
- **明確なエラーメッセージ**: Info.plistの説明文は日本語で、ユーザーにとって理解しやすい内容
- **権限拒否時の対応**: 設定アプリへの誘導UIを表示

#### Alternatives Considered

1. **従来のクロージャベース**: async/awaitの方がSwift Concurrencyと統合しやすい

#### References

- [Apple Developer: Requesting Authorization to Capture and Save Media](https://developer.apple.com/documentation/avfoundation/capture_setup/requesting_authorization_to_capture_and_save_media)

---

### 5. Strict Concurrency 対応

#### Decision

すべての型にSendable準拠を適用し、@MainActor/@ObservationIgnoredを適切に使用する。

**実装パターン**:
```swift
// Model
struct CameraSettings: Codable, Equatable, Sendable {
    // すべてのプロパティは値型またはSendable
}

// Repository (プロトコル)
protocol CameraSettingsRepository: Sendable {
    func get() async throws -> CameraSettings
    func save(_ settings: CameraSettings) async throws
}

// ViewModel
@MainActor
@Observable
final class CustomCameraViewModel {
    @ObservationIgnored
    @Dependency(\.getCameraSettingsUseCase) private var getCameraSettings

    private(set) var uiState: CustomCameraUiState

    // Observableプロパティ以外に@ObservationIgnoredを使用
}
```

#### Rationale

- **Sendable準拠**: データ型はすべてSendableにし、スレッド間で安全に共有可能にする
- **@MainActor**: ViewModelはすべて@MainActorで、UIの更新を保証
- **@ObservationIgnored**: swift-dependenciesの@Dependencyは@ObservationIgnoredと併用が必要

#### References

- [Swift Evolution: SE-0302 Sendable](https://github.com/apple/swift-evolution/blob/main/proposals/0302-concurrent-value-and-concurrent-closures.md)
- [swift-dependencies: Observation Compatibility](https://pointfreeco.github.io/swift-dependencies/main/documentation/dependencies/observation/)

---

## Summary

すべての研究トピックについて、実装方針と技術的根拠を明確にしました。主な決定事項：

1. **AVFoundation**: カスタムカメラ実装に使用、専用DispatchQueueで非同期処理
2. **Swift Testing**: Quick/NimbleからSwift Testingへ移行、@Test/@Suite/@expectマクロ使用
3. **UserDefaults**: CodableなCameraSettingsをJSONエンコードして保存
4. **カメラ権限**: async/awaitベースの権限チェック、Info.plist設定必須
5. **Strict Concurrency**: Sendable準拠、@MainActor/@ObservationIgnored適用

これらの決定事項に基づき、Phase 1のデザインフェーズに進むことができます。
