---
description: ビルドエラー・警告を抽出し修正（implement-cycleから呼び出される）(project)
argument-hint: [-c|--clean] [-o summary|full|json]
allowed-tools: Bash(scripts/bash/extract-build-errors.sh:*), Read, Edit, Glob, Grep
---

> このコマンドは `/implement-cycle` のビルド確認フェーズで呼び出されます。

## 入力: $ARGUMENTS

## 実行
```bash
./scripts/bash/extract-build-errors.sh -o summary
```

## フロー
1. スクリプト実行でエラー抽出
2. エラー箇所を確認・修正
3. 再ビルドで確認（エラー0件になるまで繰り返し）
