# AGENTS.md

This file provides guidance for AI coding agents working with this iOS application codebase.

## Language Preference

**IMPORTANT: Always respond in Japanese (日本語) when interacting with this codebase.**

This is a Japanese development project, and all explanations, suggestions, and communications should be provided in Japanese unless explicitly asked otherwise. Japanese comments may appear throughout the codebase - this is intentional for this learning project.

## Project Overview

This is a Japanese iOS application playground project (`ios-archi`) used for technical experimentation. It intentionally contains both modern and legacy technologies for learning purposes. The app uses MVVM + Layered Architecture with multi-module structure via SPM.

## Setup

### Initial Setup

```bash
# Resolve dependencies and open project
make bootstrap
```

### Build Commands

```bash
# Build the project
xcodebuild -workspace ios-archi.xcworkspace -scheme ios-archi build

# Build for testing
xcodebuild -workspace ios-archi.xcworkspace -scheme ios-archi build-for-testing

# Run tests
xcodebuild -workspace ios-archi.xcworkspace -scheme ios-archi test
```

### Code Quality Tools

```bash
# Run SwiftLint
make lint

# Auto-fix SwiftLint issues
make lint-fix

# Run SwiftFormat
make format
```

## Architecture Guidelines

### Module Structure

- **`Package/Sources/Core/`**: Foundation module with DI container (`InjectedValues`) and build helpers
- **`Package/Sources/Analytics/`**: Analytics protocol definitions
- **`Package/Sources/AnalyticsImpl/`**: Firebase Analytics implementation
- **`Package/Sources/AppFeature/`**: Main feature module with layered architecture
  - `Domain/`: Use cases (e.g., `GetSeedFromImageUseCase`, `SynchronizeWithCloudUseCase`)
  - `Data/`: Repository, DataSource, Request implementations
  - `UI/`: SwiftUI views organized by feature (e.g., `RootView/`, `ItemDetail/`, `WorldList/`)
  - `Model/`: Domain models
  - `Extension/`: Swift extensions

- **`App/ios-archi/`**: Main application target
  - Contains the app entry point (`ios_archiApp.swift`) and `AppDelegate`
  - Uses XCConfig files in `XCConfigs/` for build configuration
  - Links to Package modules as dependencies

### Project Structure

- `App/ios-archi.xcodeproj`: Application project
- `Tools/Package.swift`: Development tools (SwiftLint, SwiftFormat) via SPM
- Uses SPM for both feature modules and development tools

### Layered Architecture

Follow MVVM + Layered Architecture:

```
┌─────────────────────────────────────────┐
│  UI Layer (View / ViewModel)            │
│  - SwiftUI Views                        │
│  - ViewModels (@Observable)             │
└─────────────────┬───────────────────────┘
                  │ 依存
                  ▼
┌─────────────────────────────────────────┐
│  Domain Layer (UseCase)                 │
│  - ビジネスロジック                      │
│  - Repository Protocol定義              │
└─────────────────┬───────────────────────┘
                  │ 依存
                  ▼
┌─────────────────────────────────────────┐
│  Data Layer (Repository / DataSource)   │
│  - Repository実装 (Impl)                │
│  - DataSource, API Request              │
└─────────────────────────────────────────┘
                  ▲
                  │ 参照可
┌─────────────────────────────────────────┐
│  Model (Entity)                         │
│  - ドメインモデル                        │
│  - 他レイヤーに依存しない                │
└─────────────────────────────────────────┘
```

### アーキテクチャルール

#### 許可される依存
- UI → Domain → Data（上から下への依存のみ）
- 全レイヤー → Model（Modelは共通で参照可能）

#### 禁止される依存
- **UI → Data**: UI層がData層を直接参照してはいけない
- **Domain → UI**: Domain層がUI層を参照してはいけない
- **Data → UI**: Data層がUI層を参照してはいけない
- **Model → 他レイヤー**: Modelは他レイヤーに依存してはいけない

#### 具象クラスへの依存禁止
- UI層・Domain層は `*Impl` クラスを直接参照しない
- Protocolを通じて依存性注入を使用する

#### 命名規則
| レイヤー | サフィックス | 例 |
|---------|-------------|-----|
| UI | View, ViewModel, Screen | `ItemDetailView`, `RootViewModel` |
| Domain | UseCase, Service | `GetSeedFromImageUseCase` |
| Data | Repository, DataSource, Request | `ItemRepositoryImpl`, `CloudDataSource` |
| Model | (なし) | `Item`, `World`, `Seed` |

### Dependency Injection

Use the custom property-wrapper-based DI container:

```swift
// Define injection key in InjectedValues
extension InjectedValues {
    var myService: MyService {
        get { Self[MyServiceKey.self] }
        set { Self[MyServiceKey.self] = newValue }
    }
}

private struct MyServiceKey: InjectionKey {
    static var currentValue: MyService = MyServiceImpl()
}

// Use in code
@Injected(\.myService) var myService
```

## Code Style

### Swift Style

- **Indentation**: 4 spaces (configured in `.swiftformat`)
- **Imports**: Alphabetically sorted (enforced by SwiftFormat)
- **Naming**: Follow Swift API Design Guidelines
- **Concurrency**: Prefer Swift Concurrency (async/await) over Combine for new code
- **Access Control**: Use the most restrictive access level appropriate

### SwiftLint Rules

This project has comprehensive SwiftLint rules (`.swiftlint.yml`) with many opt-in rules enabled. Always run `make lint` before committing.

Key rules:
- Strict concurrency checking enabled
- Prefer explicit type annotations where clarity is needed
- Avoid force unwrapping
- Use `weak self` in closures to prevent retain cycles

### File Organization

- Group related files in feature-based directories
- Keep ViewModels close to their corresponding Views
- Place shared utilities in appropriate modules (Core, Extensions)

### Special Coding Considerations

- Strict concurrency checking is enabled in `Package.swift`
- The project uses both trailing closures and explicit closure syntax based on context
- CoreData resources are located in `App/ios-archi/Resources/`

## Testing Guidelines

### Test Framework

Use **Quick/Nimble** for BDD-style tests:

```swift
class MyViewModelSpec: AsyncSpec {
    override class func spec() {
        describe("ViewModel") {
            context("when action is performed") {
                it("should update state correctly") {
                    expect(viewModel.state) == .expected
                }
            }
        }
    }
}
```

### Test Location

- Unit tests: `Package/Tests/AppFeatureTests/`
- UI tests: `App/ios-archiUITests/`

### Test Naming

- Test files use `Spec` suffix (e.g., `RootViewModelSpec.swift`)
- Use descriptive test names in Japanese if needed

### Dependencies in Tests

Use `swift-dependencies` framework with mocks:

```swift
withDependencies {
    $0.myService = MyServiceMock()
} operation: {
    // Test code
}
```

### Running Tests

```bash
# Run all tests
xcodebuild -workspace ios-archi.xcworkspace -scheme ios-archi test

# Run specific test
xcodebuild -workspace ios-archi.xcworkspace -scheme ios-archi test -only-testing:AppFeatureTests/MyViewModelSpec
```

## Git Workflow

### Commit Messages

Write clear, concise commit messages in Japanese:

```
機能追加: ユーザー認証機能を実装

- ログイン画面の追加
- トークン管理の実装
- エラーハンドリングの追加
```

### Before Committing

1. Run code quality checks:
   ```bash
   make lint
   make format
   ```

2. Run tests:
   ```bash
   xcodebuild -workspace ios-archi.xcworkspace -scheme ios-archi test
   ```

3. Verify build:
   ```bash
   xcodebuild -workspace ios-archi.xcworkspace -scheme ios-archi build
   ```

### Pull Request Guidelines

- Write PR title and description in Japanese
- Include test plan in PR description
- Ensure all CI checks pass
- Request review from team members

## Important Considerations

### XCConfig Files

- Build settings are managed via XCConfig files in `App/ios-archi/XCConfigs/`
- Local configuration uses `Local.xcconfig` (not in git, see `Local.xcconfig.sample`)

### Firebase Configuration

- `GoogleService-Info.plist` contains Firebase configuration
- Keep sensitive information in `Local.xcconfig` (not committed)

### VS Code Development

The project uses `xcode-build-server` for VS Code integration:
- Configuration: `buildServer.json`
- Workspace: `ios-archi.xcworkspace`
- Scheme: `ios-archi`

## Technologies Stack

### Primary Technologies

- **Language**: Swift 5.9+
- **iOS Version**: iOS 17+
- **UI Framework**: SwiftUI
- **Architecture**: MVVM + Layered Architecture
- **Module System**: Swift Package Manager
- **Dependency Management**: Custom DI Container + swift-dependencies

### Key Libraries

- **Testing**: Quick/Nimble
- **Analytics**: Firebase Analytics
- **Crash Reporting**: Firebase Crashlytics
- **Data Persistence**: CoreData
- **Cloud Sync**: CloudKit
- **Vision**: VisionFramework

### Development Tools

- **Linting**: SwiftLint (via SPM)
- **Formatting**: SwiftFormat (via SPM)
- **Build Configuration**: XCConfig files

## Common Tasks

### Adding a New Feature

1. Create feature directory in `Package/Sources/AppFeature/UI/FeatureName/`
2. Implement ViewModel following MVVM pattern
3. Create use cases in `Domain/` if business logic is complex
4. Implement data layer in `Data/` if data access is needed
5. Add tests in `Package/Tests/AppFeatureTests/`

### Adding a New Dependency

1. Update `Package/Package.swift` with new dependency
2. Resolve packages in Xcode
3. Update this documentation if significant

### Troubleshooting Build Issues

1. Clean build folder: `xcodebuild clean -workspace ios-archi.xcworkspace -scheme ios-archi`
2. Reset package cache: `rm -rf ~/Library/Developer/Xcode/DerivedData`
3. Resolve packages: Open Xcode → File → Packages → Resolve Package Versions

## References

- [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [Quick/Nimble Documentation](https://github.com/Quick/Quick)
- [swift-dependencies](https://github.com/pointfreeco/swift-dependencies)

## Active Technologies
- Swift 5.9+ + AVFoundation (カメラ制御), Vision Framework (OCR), swift-dependencies (DI), SwiftUI (UI) (001-camera-customization)
- UserDefaults（設定永続化）, CoreData（既存のデータ層） (001-camera-customization)
- SwiftData (@Model, @Attribute, ExternalStorage), CloudKit (クラウド同期), ModelContainer/ModelConfiguration (002-swiftdata-migration)
- UserDefaults（設定管理）, Swift Testing (テストフレームワーク) (002-swiftdata-migration)

## Recent Changes
- 001-camera-customization: Added Swift 5.9+ + AVFoundation (カメラ制御), Vision Framework (OCR), swift-dependencies (DI), SwiftUI (UI)
- 002-swiftdata-migration: Added SwiftData (@Model, @Attribute, ExternalStorage), CloudKit (クラウド同期), ModelContainer/ModelConfiguration

---

## Claude Code 専用機能

> **⚠️ このセクションは Claude Code 専用です。Cursor、GitHub Copilot等は無視してください。**

### 自律開発サイクル

一通り実装が終わったら、`/implement-cycle` を実行してください。

このコマンドは以下のサブエージェントを順次呼び出します：
`build` → `run-tests` → `self-review` → `verify-app` → 完了報告

問題があれば修正して繰り返します。

### 個別指示への対応

| ユーザー指示 | 実行コマンド |
|-------------|-------------|
| 「ビルドして確認」 | `/implement-cycle` |
| 「動作確認」「アプリ確認」 | `/verify-app` |
| 「テスト実行」 | `/run-tests` |

---

## 他のAIエージェント向け（Cursor、GitHub Copilot等）

### 自律開発サイクル

実装タスクを依頼されたら、以下のサイクルを実行してください：

```
実装 → ビルド確認 → テスト → セルフレビュー → 完了
（問題あれば修正して繰り返し）
```

### 各フェーズ

1. **ビルド確認**: `./scripts/bash/build.sh 2>&1 | ./scripts/bash/extract-build-errors.sh`
2. **テスト**: `xcodebuild test -workspace ios-archi.xcworkspace -scheme ios-archi -destination 'platform=iOS Simulator,name=iPhone 16'`
3. **Lint**: `make lint`
4. **セルフレビュー**: 変更したコードを自分で読んでレビュー（上記「アーキテクチャルール」参照）
