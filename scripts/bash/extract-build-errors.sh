#!/usr/bin/env bash
# ビルドログからエラー・警告を抽出するスクリプト

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

OUTPUT_FORMAT="summary"  # summary, full, json
LOG_FILE=""

usage() {
    cat << EOF
Usage: $(basename "$0") [options] [log-file]

ビルドログからエラー・警告を抽出します。
ログファイルを指定しない場合は標準入力から読み込みます。

Options:
  -o, --output <format>    出力形式: summary, full, json (default: $OUTPUT_FORMAT)
  -h, --help               このヘルプを表示

Examples:
  ./build.sh 2>&1 | $(basename "$0")           # パイプで受け取り
  $(basename "$0") build.log                   # ログファイル指定
  $(basename "$0") -o json build.log           # JSON形式で出力
EOF
    exit 0
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -o|--output) OUTPUT_FORMAT="$2"; shift 2 ;;
        -h|--help) usage ;;
        -*) echo "Unknown option: $1"; usage ;;
        *) LOG_FILE="$1"; shift ;;
    esac
done

# エラー・警告を抽出
extract_issues() {
    local errors=()
    local warnings=()

    while IFS= read -r line; do
        if [[ "$line" =~ error: ]]; then
            errors+=("$line")
        elif [[ "$line" =~ warning: ]]; then
            warnings+=("$line")
        fi
    done

    case "$OUTPUT_FORMAT" in
        json)
            output_json errors warnings
            ;;
        full)
            output_full errors warnings
            ;;
        summary|*)
            output_summary errors warnings
            ;;
    esac

    # エラーがあれば終了コード1
    [[ ${#errors[@]} -eq 0 ]]
}

output_json() {
    local -n _errors=$1
    local -n _warnings=$2

    echo "{"
    echo '  "summary": {'
    echo "    \"error_count\": ${#_errors[@]},"
    echo "    \"warning_count\": ${#_warnings[@]}"
    echo "  },"
    echo '  "errors": ['
    local first=true
    for err in "${_errors[@]}"; do
        [[ "$first" == true ]] || echo ","
        first=false
        local escaped=$(echo "$err" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g' | sed 's/\t/\\t/g')
        echo -n "    \"$escaped\""
    done
    echo ""
    echo "  ],"
    echo '  "warnings": ['
    first=true
    for warn in "${_warnings[@]}"; do
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
    local -n _errors=$1
    local -n _warnings=$2

    echo "=== エラー (${#_errors[@]}件) ==="
    for err in "${_errors[@]}"; do
        echo "$err"
    done

    echo ""
    echo "=== 警告 (${#_warnings[@]}件) ==="
    for warn in "${_warnings[@]}"; do
        echo "$warn"
    done
}

output_summary() {
    local -n _errors=$1
    local -n _warnings=$2

    echo "# ビルド結果サマリー"
    echo ""
    echo "## 概要"
    echo "- エラー: ${#_errors[@]}件"
    echo "- 警告: ${#_warnings[@]}件"
    echo ""

    if [[ ${#_errors[@]} -gt 0 ]]; then
        echo "## エラー詳細"
        echo ""
        printf '%s\n' "${_errors[@]}" | sort -u | while IFS= read -r line; do
            echo "- \`$line\`"
        done
        echo ""
    fi

    if [[ ${#_warnings[@]} -gt 0 ]]; then
        echo "## 警告詳細 (上位20件)"
        echo ""
        printf '%s\n' "${_warnings[@]}" | sort | uniq -c | sort -rn | head -20 | while read count line; do
            echo "- ($count件) \`$line\`"
        done
        echo ""
    fi
}

# メイン処理
if [[ -n "$LOG_FILE" ]]; then
    if [[ ! -f "$LOG_FILE" ]]; then
        echo "エラー: ファイルが見つかりません: $LOG_FILE" >&2
        exit 1
    fi
    extract_issues < "$LOG_FILE"
else
    extract_issues
fi
