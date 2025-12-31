---
description: DDD・MVVM・レイヤードアーキテクチャのチェック (project)
argument-hint: [ディレクトリ]
allowed-tools: Bash(scripts/bash/check-layer-violations.sh:*), Read, Glob, Grep
---

## 入力: $ARGUMENTS

## 実行

```bash
./scripts/bash/check-layer-violations.sh $ARGUMENTS
```

## レイヤー構造
```
UI (View/ViewModel) → Domain (UseCase) → Data (Repository)
                            ↑
                        Model (Entity)
```

## チェック項目
| 項目 | 確認内容 |
|-----|---------|
| レイヤー分離 | UI→Domain→Dataの依存方向 |
| UseCase | 単一責任、ビジネスロジック集約 |
| Repository | インターフェース分離 |
| ViewModel | UIロジックのみ |
| SOLID | 各原則の遵守 |

## 違反パターン
- UI→Data直接参照
- Domain→UI参照
- 具象クラス（Impl）への直接依存
