#!/usr/bin/env bash
# ビルド実行スクリプト

set -euo pipefail

WORKSPACE="ios-archi.xcworkspace"
SCHEME="ios-archi"
CLEAN_BUILD=false
LOG_FILE=""

usage() {
    cat << EOF
Usage: $(basename "$0") [options]

プロジェクトをビルドします。

Options:
  -w, --workspace <name>   ワークスペース名 (default: $WORKSPACE)
  -s, --scheme <name>      スキーム名 (default: $SCHEME)
  -c, --clean              クリーンビルドを実行
  -l, --log <path>         ログ出力先ファイル
  -h, --help               このヘルプを表示

Examples:
  $(basename "$0")              # 通常ビルド
  $(basename "$0") -c           # クリーンビルド
  $(basename "$0") -l build.log # ログをファイルに保存
EOF
    exit 0
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -w|--workspace) WORKSPACE="$2"; shift 2 ;;
        -s|--scheme) SCHEME="$2"; shift 2 ;;
        -c|--clean) CLEAN_BUILD=true; shift ;;
        -l|--log) LOG_FILE="$2"; shift 2 ;;
        -h|--help) usage ;;
        *) echo "Unknown option: $1"; usage ;;
    esac
done

cd "$(git rev-parse --show-toplevel)"

if [[ "$CLEAN_BUILD" == true ]]; then
    echo "クリーンビルドを実行中..." >&2

    # マクロプラグインキャッシュを削除
    echo "マクロプラグインキャッシュを削除中..." >&2
    rm -rf ~/Library/Developer/Xcode/DerivedData/ios-archi-*/Build/Products/*/MacrosPlugin* 2>/dev/null || true
    rm -rf ~/Library/Developer/Xcode/DerivedData/ios-archi-*/Build/Intermediates.noindex/*/MacrosPlugin* 2>/dev/null || true
    rm -rf .build/ 2>/dev/null || true

    xcodebuild clean \
        -workspace "$WORKSPACE" \
        -scheme "$SCHEME" \
        -quiet 2>/dev/null || true
fi

echo "ビルド実行中..." >&2

DESTINATION="${DESTINATION:-platform=iOS Simulator,name=iPhone 17}"

if [[ -n "$LOG_FILE" ]]; then
    xcodebuild \
        -workspace "$WORKSPACE" \
        -scheme "$SCHEME" \
        -sdk iphonesimulator \
        -destination "$DESTINATION" \
        2>&1 | tee "$LOG_FILE"
else
    xcodebuild \
        -workspace "$WORKSPACE" \
        -scheme "$SCHEME" \
        -sdk iphonesimulator \
        -destination "$DESTINATION"
fi

echo "ビルド完了" >&2
