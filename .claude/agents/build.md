---
name: build
description: ビルド実行（implement-cycleから呼び出される）
tools: Bash, Read, Edit, Glob, Grep
model: sonnet
---

# ビルドエージェント

> このエージェントは `/verify-cycle` のビルド確認フェーズで呼び出されます。

## 実行
```bash
./scripts/bash/build.sh 2>&1 | ./scripts/bash/extract-build-errors.sh
```

## フロー
1. ビルド実行
2. エラー抽出・確認
3. エラーがあれば修正して再実行
