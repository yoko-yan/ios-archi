---
name: review-architecture
description: DDD・MVVM・レイヤードアーキテクチャのチェック
tools: Read, Glob, Grep
model: sonnet
---

# アーキテクチャレビューエージェント

## 実行
```bash
./scripts/bash/check-layer-violations.sh
```

## レイヤー構造
UI → Domain → Data ← Model

## チェック項目
- レイヤー分離（依存方向）
- UseCase単一責任
- Repository抽象化
- SOLID原則
