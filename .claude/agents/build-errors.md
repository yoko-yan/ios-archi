---
name: build-errors
description: ビルドエラー・警告を抽出し修正
tools: Bash, Read, Edit, Glob, Grep
model: sonnet
---

# ビルドエラー抽出エージェント

## 実行
```bash
./scripts/bash/extract-build-errors.sh -o summary
./scripts/bash/extract-build-errors.sh -c -o summary  # クリーンビルド
```

## フロー
1. スクリプト実行でエラー抽出
2. エラー箇所を確認
3. 修正を適用
4. 再ビルドで確認
