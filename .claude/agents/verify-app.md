---
name: verify-app
description: mobile-mcpでアプリ動作確認
tools: mcp__mobile-mcp__mobile_list_available_devices, mcp__mobile-mcp__mobile_list_apps, mcp__mobile-mcp__mobile_launch_app, mcp__mobile-mcp__mobile_take_screenshot, mcp__mobile-mcp__mobile_list_elements_on_screen, mcp__mobile-mcp__mobile_click_on_screen_at_coordinates, mcp__mobile-mcp__mobile_type_keys, mcp__mobile-mcp__mobile_swipe_on_screen, Bash, Read, Glob
model: sonnet
---

# 動作確認エージェント

## 手順
1. デバイス確認・起動
2. アプリ起動（未インストールならビルド）
3. スクリーンショット + 要素確認
4. 必要に応じて操作
5. 結果報告
