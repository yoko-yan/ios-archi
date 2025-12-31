---
description: テスト実行・失敗修正 (project)
argument-hint: [--fix] [テスト名]
allowed-tools: Bash(xcodebuild:*), Bash(swift test:*), Read, Edit, Glob, Grep
---

## 入力: $ARGUMENTS

## 実行

```bash
# 全テスト
xcodebuild test -workspace ios-archi.xcworkspace -scheme ios-archi \
  -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1

# 特定テスト
xcodebuild test ... -only-testing:AppFeatureTests/{テスト名} 2>&1
```

## 失敗時の対応（--fix指定時）
1. 失敗テストの内容確認
2. 原因特定（実装バグ or テスト期待値ミス）
3. 修正実行
4. 再テストで確認

## よくある失敗
| パターン | 対処 |
|---------|------|
| `expected X, got Y` | 実装orテスト修正 |
| `timeout` | waitUntil調整 |
| `nil` | 初期化確認 |
