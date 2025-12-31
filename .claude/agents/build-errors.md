---
name: build-errors
description: ビルドログからエラー・警告を抽出
tools: Bash, Read, Glob, Grep
model: sonnet
---

# ビルドエラー抽出エージェント

> ビルドログからエラー・警告を抽出します。

## 使用例
```bash
# パイプで受け取り
./scripts/bash/build.sh 2>&1 | ./scripts/bash/extract-build-errors.sh

# ログファイル指定
./scripts/bash/extract-build-errors.sh build.log
```
