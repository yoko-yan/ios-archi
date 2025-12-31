---
description: ビルドログからエラー・警告を抽出 (project)
argument-hint: [-o summary|full|json] [log-file]
allowed-tools: Bash(scripts/bash/extract-build-errors.sh:*), Read, Glob, Grep
---

> ビルドログからエラー・警告を抽出します。

## 入力: $ARGUMENTS

## 使用例
```bash
# パイプで受け取り
./scripts/bash/build.sh 2>&1 | ./scripts/bash/extract-build-errors.sh

# ログファイル指定
./scripts/bash/extract-build-errors.sh build.log
```

## オプション
- `-o summary`: Markdownサマリー（デフォルト）
- `-o full`: 全出力
- `-o json`: JSON形式
