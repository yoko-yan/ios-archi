---
description: mobile-mcpでアプリ動作確認 (project)
argument-hint: [画面名やシナリオ]
allowed-tools: mcp__mobile-mcp, Bash(xcodebuild:*), Bash(xcrun simctl:*), Read, Glob
---

## 入力: $ARGUMENTS

## 手順

1. **デバイス確認**: `mobile_list_available_devices`
2. **アプリ起動**: `mobile_launch_app`（未インストールならビルド→インストール）
3. **確認**: `mobile_take_screenshot` + `mobile_list_elements_on_screen`
4. **操作**: 必要に応じてタップ、入力、スワイプ

## 操作一覧
| 操作 | ツール |
|-----|-------|
| スクリーンショット | `mobile_take_screenshot` |
| 要素取得 | `mobile_list_elements_on_screen` |
| タップ | `mobile_click_on_screen_at_coordinates` |
| 入力 | `mobile_type_keys` |
| スワイプ | `mobile_swipe_on_screen` |

## 結果報告
確認画面、実行操作、問題点をスクリーンショット付きで報告
