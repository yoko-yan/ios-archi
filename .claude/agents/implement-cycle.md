---
name: implement-cycle
description: 自律実装サイクル（実装→ビルド→テスト→レビュー→修正）を実行
tools: Bash, Read, Edit, Write, Glob, Grep, mcp__mobile-mcp__mobile_take_screenshot, mcp__mobile-mcp__mobile_launch_app
model: sonnet
---

# 自律実装エージェント

## サイクル
実装 → ビルド確認 → テスト → レビュー → 動作確認 → 完了
（問題あれば修正して繰り返し）

## コマンド
```bash
./scripts/bash/extract-build-errors.sh -o summary  # ビルド確認
./scripts/bash/self-review-check.sh                # セルフレビュー
./scripts/bash/check-layer-violations.sh           # レイヤー違反
```

## ルール
- ビルドエラー修正: 最大5回
- テスト修正: 最大3回
- 超えたらユーザーに相談
