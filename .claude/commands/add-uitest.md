---
description: Create UI test for a specific screen using mobile-mcp
---

指定された画面のUIテストを作成してください。

**最初に UITestingGuide.md を探してガイドに従って実行すること。見つからない場合はユーザーに確認。**

## 実行内容

1. mobile-mcp でアプリを操作し、対象画面のUI要素を把握
2. ScreenGuide.md で画面構造を確認
3. 既存のPage Objectを参照し、必要に応じて修正・追加
4. テストコードを生成
5. 実機でテストを実行し、成功するまで修正

## 重要な制約

- **プロダクトコード変更は原則禁止**（必要な場合は必ずユーザーに確認）
- テスト追加フローと重要ルールは UITestingGuide.md を参照
- タスク終了前に必ずテストを実行して成功を確認
