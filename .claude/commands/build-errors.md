---
description: ビルドエラー・警告を抽出し修正 (project)
argument-hint: [-c|--clean] [-o summary|full|json]
allowed-tools: Bash(scripts/bash/extract-build-errors.sh:*), Bash(make build-errors:*), Read, Edit, Glob, Grep
---

## 入力: $ARGUMENTS

## 実行

```bash
./scripts/bash/extract-build-errors.sh $ARGUMENTS
```

デフォルト: `-o summary`

## オプション
- `-c`: クリーンビルド
- `-o summary`: Markdownサマリー（デフォルト）
- `-o full`: 全出力
- `-o json`: JSON形式

## エラー時の対応
1. エラー箇所を特定
2. 該当ファイルを確認
3. 修正を適用
4. 再ビルドで確認
