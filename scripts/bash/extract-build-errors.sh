#!/usr/bin/env bash
# ビルドログからエラー・警告を抽出するスクリプト

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# デフォルト値
WORKSPACE="ios-archi.xcworkspace"
SCHEME="ios-archi"
BUILD_LOG_FILE=""
OUTPUT_FORMAT="summary"  # summary, full, json
CLEAN_BUILD=false
SKIP_BUILD=false

usage() {
    cat << EOF
Usage: $(basename "$0") [options]

ビルドログからエラー・警告を抽出します。

Options:
  -w, --workspace <name>   ワークスペース名 (default: $WORKSPACE)
  -s, --scheme <name>      スキーム名 (default: $SCHEME)
  -l, --log-file <path>    既存のビルドログを使用（ビルドをスキップ）
  -o, --output <format>    出力形式: summary, full, json (default: $OUTPUT_FORMAT)
  -c, --clean              クリーンビルドを実行
  --skip-build             ビルドをスキップ（-lと同時に使用）
  -h, --help               このヘルプを表示

Examples:
  $(basename "$0")                     # 通常ビルドしてエラーを抽出
  $(basename "$0") -c                  # クリーンビルドしてエラーを抽出
  $(basename "$0") -l build.log        # 既存ログから抽出
  $(basename "$0") -o json             # JSON形式で出力
EOF
    exit 0
}

# 引数解析
while [[ $# -gt 0 ]]; do
    case "$1" in
        -w|--workspace) WORKSPACE="$2"; shift 2 ;;
        -s|--scheme) SCHEME="$2"; shift 2 ;;
        -l|--log-file) BUILD_LOG_FILE="$2"; SKIP_BUILD=true; shift 2 ;;
        -o|--output) OUTPUT_FORMAT="$2"; shift 2 ;;
        -c|--clean) CLEAN_BUILD=true; shift ;;
        --skip-build) SKIP_BUILD=true; shift ;;
        -h|--help) usage ;;
        *) echo "Unknown option: $1"; usage ;;
    esac
done

REPO_ROOT=$(get_repo_root)
cd "$REPO_ROOT"

# 一時ファイルの設定
if [[ -z "$BUILD_LOG_FILE" ]]; then
    BUILD_LOG_FILE=$(mktemp /tmp/build_log_XXXXXX.txt)
    trap "rm -f $BUILD_LOG_FILE" EXIT
fi

# ビルド実行
run_build() {
    echo "=== ビルド開始 ===" >&2

    if [[ "$CLEAN_BUILD" == true ]]; then
        echo "クリーンビルドを実行中..." >&2
        xcodebuild clean \
            -workspace "$WORKSPACE" \
            -scheme "$SCHEME" \
            -quiet 2>/dev/null || true
    fi

    echo "ビルド実行中..." >&2
    xcodebuild \
        -workspace "$WORKSPACE" \
        -scheme "$SCHEME" \
        -sdk iphonesimulator \
        -destination "generic/platform=iOS Simulator" \
        2>&1 | tee "$BUILD_LOG_FILE" >/dev/null

    local exit_code=${PIPESTATUS[0]}
    echo "ビルド完了 (exit code: $exit_code)" >&2
    return $exit_code
}

# エラー・警告を抽出
extract_issues() {
    local log_file="$1"
    local errors=()
    local warnings=()

    while IFS= read -r line; do
        if [[ "$line" =~ error: ]]; then
            errors+=("$line")
        elif [[ "$line" =~ warning: ]]; then
            warnings+=("$line")
        fi
    done < "$log_file"

    # エラーをソート（重複を除去しつつカウント）
    declare -A error_counts
    declare -A warning_counts

    for err in "${errors[@]}"; do
        # ファイルパスと行番号を除去して警告内容だけでグループ化
        local key=$(echo "$err" | sed -E 's/^[^:]+:[0-9]+:[0-9]+: //' | sed -E 's/^[^:]+: //')
        error_counts["$key"]=$((${error_counts["$key"]:-0} + 1))
    done

    for warn in "${warnings[@]}"; do
        local key=$(echo "$warn" | sed -E 's/^[^:]+:[0-9]+:[0-9]+: //' | sed -E 's/^[^:]+: //')
        warning_counts["$key"]=$((${warning_counts["$key"]:-0} + 1))
    done

    case "$OUTPUT_FORMAT" in
        json)
            output_json "${errors[@]}" -- "${warnings[@]}"
            ;;
        full)
            output_full "${errors[@]}" -- "${warnings[@]}"
            ;;
        summary|*)
            output_summary error_counts warning_counts "${errors[@]}" -- "${warnings[@]}"
            ;;
    esac
}

output_json() {
    local in_errors=true
    local errors=()
    local warnings=()

    for arg in "$@"; do
        if [[ "$arg" == "--" ]]; then
            in_errors=false
            continue
        fi
        if [[ "$in_errors" == true ]]; then
            errors+=("$arg")
        else
            warnings+=("$arg")
        fi
    done

    echo "{"
    echo '  "summary": {'
    echo "    \"error_count\": ${#errors[@]},"
    echo "    \"warning_count\": ${#warnings[@]}"
    echo "  },"
    echo '  "errors": ['
    local first=true
    for err in "${errors[@]}"; do
        [[ "$first" == true ]] || echo ","
        first=false
        # JSONエスケープ
        local escaped=$(echo "$err" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g' | sed 's/\t/\\t/g')
        echo -n "    \"$escaped\""
    done
    echo ""
    echo "  ],"
    echo '  "warnings": ['
    first=true
    for warn in "${warnings[@]}"; do
        [[ "$first" == true ]] || echo ","
        first=false
        local escaped=$(echo "$warn" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g' | sed 's/\t/\\t/g')
        echo -n "    \"$escaped\""
    done
    echo ""
    echo "  ]"
    echo "}"
}

output_full() {
    local in_errors=true
    local errors=()
    local warnings=()

    for arg in "$@"; do
        if [[ "$arg" == "--" ]]; then
            in_errors=false
            continue
        fi
        if [[ "$in_errors" == true ]]; then
            errors+=("$arg")
        else
            warnings+=("$arg")
        fi
    done

    echo "=== エラー (${#errors[@]}件) ==="
    for err in "${errors[@]}"; do
        echo "$err"
    done

    echo ""
    echo "=== 警告 (${#warnings[@]}件) ==="
    for warn in "${warnings[@]}"; do
        echo "$warn"
    done
}

output_summary() {
    local -n _error_counts=$1
    local -n _warning_counts=$2
    shift 2

    local in_errors=true
    local errors=()
    local warnings=()

    for arg in "$@"; do
        if [[ "$arg" == "--" ]]; then
            in_errors=false
            continue
        fi
        if [[ "$in_errors" == true ]]; then
            errors+=("$arg")
        else
            warnings+=("$arg")
        fi
    done

    echo "# ビルド結果サマリー"
    echo ""
    echo "## 概要"
    echo "- エラー: ${#errors[@]}件"
    echo "- 警告: ${#warnings[@]}件"
    echo ""

    if [[ ${#errors[@]} -gt 0 ]]; then
        echo "## エラー詳細"
        echo ""
        # 重複を除去してソート
        printf '%s\n' "${errors[@]}" | sort -u | while IFS= read -r line; do
            echo "- \`$line\`"
        done
        echo ""
    fi

    if [[ ${#warnings[@]} -gt 0 ]]; then
        echo "## 警告詳細 (上位20件)"
        echo ""
        # 重複を除去してソート、上位20件
        printf '%s\n' "${warnings[@]}" | sort | uniq -c | sort -rn | head -20 | while read count line; do
            echo "- ($count件) \`$line\`"
        done
        echo ""
    fi
}

# メイン処理
main() {
    local build_success=true

    if [[ "$SKIP_BUILD" != true ]]; then
        run_build || build_success=false
    fi

    if [[ ! -f "$BUILD_LOG_FILE" ]]; then
        echo "エラー: ビルドログファイルが見つかりません: $BUILD_LOG_FILE" >&2
        exit 1
    fi

    extract_issues "$BUILD_LOG_FILE"

    if [[ "$build_success" == false ]]; then
        exit 1
    fi
}

main
