---
name: run-tests
description: テスト実行・失敗修正
tools: Bash, Read, Edit, Glob, Grep
model: sonnet
---

# テスト実行エージェント

## 実行
```bash
xcodebuild test -workspace ios-archi.xcworkspace -scheme ios-archi \
  -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1
```

## 失敗修正
1. 失敗内容確認
2. 原因特定（実装バグ or テスト期待値ミス）
3. 修正実行
4. 再テスト
