#!/usr/bin/env bash
# ビルドログからエラー・警告を抽出するスクリプト

set -euo pipefail

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

# グローバル配列（bash 3.2互換のため）
ERRORS=()
WARNINGS=()

# エラー・警告を抽出
extract_issues() {
    ERRORS=()
    WARNINGS=()

    while IFS= read -r line; do
        if [[ "$line" =~ error: ]]; then
            ERRORS+=("$line")
        elif [[ "$line" =~ warning: ]]; then
            WARNINGS+=("$line")
        fi
    done

    case "$OUTPUT_FORMAT" in
        json)
            output_json
            ;;
        full)
            output_full
            ;;
        summary|*)
            output_summary
            ;;
    esac

    # エラーがあれば終了コード1
    [[ ${#ERRORS[@]} -eq 0 ]]
}

output_json() {
    echo "{"
    echo '  "summary": {'
    echo "    \"error_count\": ${#ERRORS[@]},"
    echo "    \"warning_count\": ${#WARNINGS[@]}"
    echo "  },"
    echo '  "errors": ['
    local first=true
    if [[ ${#ERRORS[@]} -gt 0 ]]; then
        for err in "${ERRORS[@]}"; do
            [[ "$first" == true ]] || echo ","
            first=false
            local escaped=$(echo "$err" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g' | sed 's/\t/\\t/g')
            echo -n "    \"$escaped\""
        done
    fi
    echo ""
    echo "  ],"
    echo '  "warnings": ['
    first=true
    if [[ ${#WARNINGS[@]} -gt 0 ]]; then
        for warn in "${WARNINGS[@]}"; do
            [[ "$first" == true ]] || echo ","
            first=false
            local escaped=$(echo "$warn" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g' | sed 's/\t/\\t/g')
            echo -n "    \"$escaped\""
        done
    fi
    echo ""
    echo "  ]"
    echo "}"
}

output_full() {
    echo "=== エラー (${#ERRORS[@]}件) ==="
    if [[ ${#ERRORS[@]} -gt 0 ]]; then
        for err in "${ERRORS[@]}"; do
            echo "$err"
        done
    fi

    echo ""
    echo "=== 警告 (${#WARNINGS[@]}件) ==="
    if [[ ${#WARNINGS[@]} -gt 0 ]]; then
        for warn in "${WARNINGS[@]}"; do
            echo "$warn"
        done
    fi
}

output_summary() {
    echo "# ビルド結果サマリー"
    echo ""
    echo "## 概要"
    echo "- エラー: ${#ERRORS[@]}件"
    echo "- 警告: ${#WARNINGS[@]}件"
    echo ""

    if [[ ${#ERRORS[@]} -gt 0 ]]; then
        echo "## エラー詳細"
        echo ""
        printf '%s\n' "${ERRORS[@]}" | sort -u | while IFS= read -r line; do
            echo "- \`$line\`"
        done
        echo ""
    fi

    if [[ ${#WARNINGS[@]} -gt 0 ]]; then
        echo "## 警告詳細 (上位20件)"
        echo ""
        printf '%s\n' "${WARNINGS[@]}" | sort | uniq -c | sort -rn | head -20 | while IFS= read -r line; do
            # 先頭の空白と数字を分離
            local count="${line%%[!0-9 ]*}"
            local msg="${line#*[0-9] }"
            count="${count// /}"  # 空白を除去
            echo "- (${count}件) \`$msg\`"
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
