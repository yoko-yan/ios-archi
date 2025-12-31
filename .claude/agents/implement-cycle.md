---
name: implement-cycle
description: 実装後の確認サイクル（ビルド→テスト→レビュー→動作確認）
tools: Bash, Read, Edit, Write, Glob, Grep, mcp__mobile-mcp__mobile_take_screenshot, mcp__mobile-mcp__mobile_launch_app
model: sonnet
---

# 実装後確認エージェント

> 一通り実装が終わったら、このエージェントを実行してください。

## サイクル
`build` → `run-tests` → `self-review` → `verify-app` → 完了報告
（問題あれば修正して繰り返し）

## ルール
- 各フェーズで問題があれば修正
- 3回試行しても解消しない場合はユーザーに相談
