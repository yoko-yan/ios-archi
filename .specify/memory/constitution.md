<!--
SYNC IMPACT REPORT
==================
Version change: 1.0.0 → 1.1.0
Modified principles:
  - II. Testing Standards: Quick/Nimble → Swift Testing に変更
  - II. Testing Standards: Sourcery モック生成を削除
Added sections: N/A
Removed sections: N/A
Templates requiring updates:
  - .specify/templates/plan-template.md ✅ (Constitution Check section aligns)
  - .specify/templates/spec-template.md ✅ (Success Criteria aligns with performance principles)
  - .specify/templates/tasks-template.md ✅ (Test phases align with testing standards)
Follow-up TODOs: None
-->

# ios-archi Constitution

## Core Principles

### I. Code Quality (コード品質)

本プロジェクトにおけるコード品質の基準を定義する。

**必須要件**:
- すべてのコードは SwiftLint のルールに準拠しなければならない（MUST）
- すべてのコードは SwiftFormat のフォーマット規則に従わなければならない（MUST）
- Strict Concurrency チェックを有効にした状態でビルドが通らなければならない（MUST）
- Force Unwrap（`!`）の使用は、明示的な理由がある場合を除き禁止（MUST NOT）
- 循環参照を防ぐため、クロージャ内での `weak self` の使用を徹底しなければならない（MUST）

**推奨事項**:
- MVVM + レイヤードアーキテクチャの依存方向（UI → Domain → Data）に従うべきである（SHOULD）
- 新規コードでは Combine より Swift Concurrency（async/await）を優先すべきである（SHOULD）
- アクセス修飾子は最も制限的なレベルを使用すべきである（SHOULD）

**根拠**: 一貫したコード品質により、学習目的のプレイグラウンドプロジェクトであっても
保守性と可読性が維持され、リファクタリングの学習効果も高まる。

### II. Testing Standards (テスト基準)

テストの記述方法と品質基準を定義する。

**必須要件**:
- テストは Swift Testing フレームワークを使用して記述しなければならない（MUST）
- テストファイルは `Tests` サフィックスを使用しなければならない（例: `RootViewModelTests.swift`）（MUST）
- テストの依存関係は swift-dependencies フレームワークを使用して管理しなければならない（MUST）
- モックは手動で作成するか、プロトコルベースの実装を使用しなければならない（MUST）

**テスト構造**:
- `@Test` マクロでテスト関数を定義
- `@Suite` マクロでテストをグループ化
- `#expect` マクロでアサーションを記述

**推奨事項**:
- ユースケース層のテストは単体テストとして記述すべきである（SHOULD）
- データ層のテストは統合テストとして記述すべきである（SHOULD）
- パラメータ化テストを活用して複数のケースを効率的にテストすべきである（SHOULD）

**根拠**: Swift Testing は Apple 公式のテストフレームワークであり、
Swift 言語との統合が深く、より簡潔で表現力豊かなテストが記述できる。

### III. User Experience Consistency (UX一貫性)

ユーザー体験の一貫性を確保するための基準を定義する。

**必須要件**:
- UI コンポーネントは SwiftUI を使用して実装しなければならない（MUST）
- すべての UI は iOS 17+ の機能セットに準拠しなければならない（MUST）
- エラーメッセージはユーザーにとって理解可能な日本語で表示しなければならない（MUST）
- ローディング状態、エラー状態、空状態の UI を明示的に定義しなければならない（MUST）

**推奨事項**:
- Xcode Preview を使用して UI の動作確認を行うべきである（SHOULD）
- アクセシビリティ対応（VoiceOver、Dynamic Type）を考慮すべきである（SHOULD）
- アニメーションは iOS 標準のタイミングと曲線を使用すべきである（SHOULD）

**根拠**: 学習プロジェクトであっても、一貫した UX パターンを維持することで、
実際のプロダクト開発で必要となるスキルを習得できる。

### IV. Performance Requirements (パフォーマンス要件)

アプリケーションのパフォーマンス基準を定義する。

**必須要件**:
- メインスレッドをブロックする処理は禁止（MUST NOT）
- 重い処理は必ずバックグラウンドスレッドで実行しなければならない（MUST）
- メモリリークを防ぐためのライフサイクル管理を徹底しなければならない（MUST）

**目標値**:
- UI 操作は 60fps を維持すること（TARGET）
- 画面遷移は 300ms 以内に完了すること（TARGET）
- アプリ起動は 2 秒以内にメイン画面を表示すること（TARGET）

**推奨事項**:
- Instruments を使用したパフォーマンス計測を定期的に実施すべきである（SHOULD）
- 大量データを扱う場合はページネーションまたは遅延読み込みを使用すべきである（SHOULD）
- 画像はキャッシュと適切なサイズでの表示を行うべきである（SHOULD）

**根拠**: パフォーマンス要件を明示することで、開発初期からパフォーマンスを意識した
実装が可能になり、後からの最適化コストを削減できる。

## Quality Gates (品質ゲート)

コードがマージ可能となる前に満たすべき条件を定義する。

**必須ゲート**:
1. `make lint` がエラーなしで完了すること
2. `make format` による変更がないこと（既にフォーマット済みであること）
3. `xcodebuild build` が警告なしで成功すること
4. すべてのテストが `xcodebuild test` で成功すること

**推奨ゲート**:
5. 新機能には対応するテストが含まれていること
6. ドキュメント（コードコメント）が適切に更新されていること

## Development Workflow (開発ワークフロー)

### コミットメッセージ規約

コミットメッセージは日本語で記述し、以下の形式に従う:

```
<タイプ>: <概要>

- <詳細1>
- <詳細2>
```

**タイプ**:
- `機能追加`: 新機能の実装
- `修正`: バグ修正
- `改善`: パフォーマンス改善やリファクタリング
- `テスト`: テストの追加・修正
- `ドキュメント`: ドキュメントの更新
- `設定`: 設定ファイルの変更

### ブランチ戦略

- `main`: 安定版ブランチ
- 機能ブランチは `feature/` プレフィックスを使用

## Governance

### 憲章の優先度

本憲章は他のすべてのプラクティスおよびガイドラインに優先する。
本憲章の原則に違反するコードはマージしてはならない（MUST NOT）。

### 改訂手順

1. 改訂提案を文書化する
2. 影響を受けるファイル（テンプレート、ドキュメント）を特定する
3. すべての関連ファイルを同時に更新する
4. バージョン番号を適切に更新する

### バージョニング方針

セマンティックバージョニングに従う:
- **MAJOR**: 後方互換性のない原則の削除または再定義
- **MINOR**: 新しい原則/セクションの追加または重要な拡張
- **PATCH**: 明確化、言い回しの修正、非意味的な改良

### コンプライアンスレビュー

すべてのプルリクエスト/レビューにおいて、本憲章への準拠を確認しなければならない（MUST）。
複雑さの追加は正当な理由を示さなければならない（MUST）。

ランタイム開発ガイダンスについては `CLAUDE.md` を参照すること。

**Version**: 1.1.0 | **Ratified**: 2025-12-14 | **Last Amended**: 2025-12-14
