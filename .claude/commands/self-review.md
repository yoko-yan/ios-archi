---
description: セルフレビュー・自動修正 (project)
argument-hint: [--fix] [ファイルパス]
allowed-tools: Bash, Read, Edit, Glob, Grep
---

## 入力: $ARGUMENTS

## 手順
1. 変更ファイルを特定（`git diff --name-only`）
2. 各ファイルのコードを読んでレビュー
3. 問題があれば修正
4. `make lint` で最終確認

## レビュー観点
- レイヤー違反（UI→Data直接参照など）
- 未使用import・変数
- 強制アンラップ（!）の適切性
- エラーハンドリング
- 命名規則
- コードの重複

## 修正（--fix指定時）
検出した問題をEditツールで修正
