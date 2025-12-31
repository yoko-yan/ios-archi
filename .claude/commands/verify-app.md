---
description: 動作確認 - mobile-mcpでアプリをシミュレータ上で確認 (project)
argument-hint: [画面名やシナリオ]
allowed-tools: mcp__mobile-mcp, Bash(xcodebuild:*), Bash(xcrun simctl:*), Read, Glob
---

> 「動作確認」「アプリ確認」と指示された場合、または `/implement-cycle` から呼び出されます。

## 入力: $ARGUMENTS

## 手順
1. デバイス確認・起動
2. アプリ起動（未インストールならビルド→インストール）
3. スクリーンショット + 要素確認
4. 必要に応じて操作
5. 結果報告（スクリーンショット付き）
