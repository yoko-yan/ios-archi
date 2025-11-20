---
description: Create UI test for a specific screen using mobile-mcp
argument-hint: [--no-prod-changes]
allowed-tools: mcp__mobile-mcp, Bash(xcodebuild:*), Bash(xcrun simctl:*), Read, Edit, Write, Glob
---

mobile-mcp（必須）を使ってアプリを起動し、指定された画面のUIテストを作成してください。

**最初に UI_TESTING_GUIDE.md を探してガイドに従って実行すること。見つからない場合はユーザーに確認。**

## mobile-mcp設定
- **デバイス**: 起動中のシミュレータを優先使用。なければiPhone 16を起動
- WebDriverAgentが未セットアップの場合はユーザーに確認

## 実行内容

1. mobile-mcp でアプリを操作し、対象画面のUI要素を把握
2. SCREEN_GUIDE.md で画面構造を確認
3. 既存のPage Objectを参照し、必要に応じて修正・追加
4. テストコードを生成（画面ごとに別ファイル: `{画面名}UITests.swift`）
5. 実機でテストを実行し、成功するまで修正

## 重要な制約

- `--no-prod-changes`: プロダクトコード変更禁止
- テスト追加フローと重要ルールは UI_TESTING_GUIDE.md を参照
- タスク終了前に必ずテストを実行して成功を確認
- **1度に作成するテストケースは3つまで**
- 3つ以上作成が必要な場合は、ユーザーにどれを作成するか選んでもらう
- 各テスト完了後、続けるかユーザーに確認する
