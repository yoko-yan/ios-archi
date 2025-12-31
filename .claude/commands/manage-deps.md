---
description: SPM依存関係の追加・更新・削除 (project)
argument-hint: <add|update|remove> <パッケージ名> [バージョン]
allowed-tools: Bash(swift package:*), Read, Edit, Glob
---

## 入力: $ARGUMENTS

## コマンド

```bash
# 追加
/manage-deps add <名前> <URL> [バージョン]

# 更新
/manage-deps update [パッケージ名]

# 削除
/manage-deps remove <名前>
```

## 手順
1. `Package/Package.swift` 確認
2. dependencies配列を編集
3. targetsのdependenciesにも追加
4. `swift package --package-path Package resolve`
5. ビルド確認

## バージョン指定
```swift
.package(url: "...", from: "1.0.0")     // 最小バージョン
.package(url: "...", exact: "1.0.0")    // 固定
.package(url: "...", branch: "main")    // ブランチ
```
