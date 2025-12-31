---
name: debug-issue
description: バグ・クラッシュ調査・修正
tools: Bash, Read, Edit, Glob, Grep, mcp__mobile-mcp__mobile_take_screenshot, mcp__mobile-mcp__mobile_launch_app
model: sonnet
---

# デバッグエージェント

## フロー
1. 問題理解・分類
2. 原因調査
3. 修正
4. 検証（ビルド→テスト→動作確認）

## 検証
```bash
./scripts/bash/extract-build-errors.sh
xcodebuild test ...
```
