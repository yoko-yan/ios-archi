---
description: ビルド実行 (project)
argument-hint: [-c|--clean]
allowed-tools: Bash(scripts/bash/build.sh:*), Read, Edit, Glob, Grep
---

> ビルドを実行します。エラー抽出は `/build-errors` を使用してください。

## 入力: $ARGUMENTS

## 実行
```bash
./scripts/bash/build.sh $ARGUMENTS 2>&1 | ./scripts/bash/extract-build-errors.sh
```

## オプション
- `-c`: クリーンビルド

## エラー時
エラーがあれば修正して再実行
