---
description: バグ・クラッシュ調査・修正 (project)
argument-hint: <問題の説明またはエラーメッセージ>
allowed-tools: Bash, Read, Edit, Glob, Grep, mcp__mobile-mcp
---

## 入力: $ARGUMENTS

## フロー
1. **理解**: エラー情報収集、問題分類
2. **調査**: コード検索、原因特定
3. **修正**: 最小限の変更で修正
4. **検証**: ビルド→テスト→動作確認

## よくあるクラッシュ
| パターン | 原因 | 対処 |
|---------|------|------|
| `EXC_BAD_ACCESS` | メモリ問題 | 参照管理確認 |
| `Index out of range` | 配列範囲外 | bounds確認 |
| `found nil` | 強制アンラップ | guard使用 |

## Swift Concurrency
| エラー | 対処 |
|--------|------|
| `actor-isolated` | await追加 |
| `Sendable` | @Sendable対応 |
| `MainActor` | @MainActor追加 |
