#!/usr/bin/env bash
# レイヤー違反検出スクリプト
# importパターン分析でMVVM+レイヤードアーキテクチャの違反を検出

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# デフォルト値
OUTPUT_FORMAT="summary"  # summary, json
TARGET_DIR=""

# レイヤー定義
UI_DIR="Package/Sources/AppFeature/UI"
DOMAIN_DIR="Package/Sources/AppFeature/Domain"
DATA_DIR="Package/Sources/AppFeature/Data"
MODEL_DIR="Package/Sources/AppFeature/Model"

usage() {
    cat << EOF
Usage: $(basename "$0") [options] [directory]

レイヤードアーキテクチャの違反を検出します。

レイヤー構造:
  UI (View/ViewModel) → Domain (UseCase) → Data (Repository)
                              ↑
                          Model (Entity)

違反パターン:
  - UI層がData層を直接参照
  - Domain層がUI層を参照
  - Data層がUI層を参照

Options:
  -o, --output <format>    出力形式: summary, json (default: $OUTPUT_FORMAT)
  -h, --help               このヘルプを表示

Examples:
  $(basename "$0")                           # 全体をチェック
  $(basename "$0") Package/Sources/AppFeature/UI/  # UI層のみチェック
EOF
    exit 0
}

# 引数解析
while [[ $# -gt 0 ]]; do
    case "$1" in
        -o|--output) OUTPUT_FORMAT="$2"; shift 2 ;;
        -h|--help) usage ;;
        -*) echo "Unknown option: $1"; usage ;;
        *) TARGET_DIR="$1"; shift ;;
    esac
done

REPO_ROOT=$(get_repo_root)
cd "$REPO_ROOT"

# ファイルがどのレイヤーに属するか判定
get_layer() {
    local file="$1"
    if [[ "$file" == *"/UI/"* ]]; then
        echo "UI"
    elif [[ "$file" == *"/Domain/"* ]]; then
        echo "Domain"
    elif [[ "$file" == *"/Data/"* ]]; then
        echo "Data"
    elif [[ "$file" == *"/Model/"* ]]; then
        echo "Model"
    else
        echo "Other"
    fi
}

# importからレイヤーを推測
get_import_layer() {
    local import_name="$1"

    # Data層のクラス名パターン
    if [[ "$import_name" =~ (Repository|DataSource|Request|Response)$ ]]; then
        echo "Data"
    # UI層のクラス名パターン
    elif [[ "$import_name" =~ (View|ViewModel|Screen|Page)$ ]]; then
        echo "UI"
    # Domain層のクラス名パターン
    elif [[ "$import_name" =~ (UseCase|Service|Interactor)$ ]]; then
        echo "Domain"
    else
        echo "Unknown"
    fi
}

# ファイル内のimportを解析
analyze_imports() {
    local file="$1"
    local file_layer=$(get_layer "$file")
    local violations=()

    # ファイル内の参照を検索（import以外の参照も含む）
    # Data層の具象クラスへの参照
    if [[ "$file_layer" == "UI" ]]; then
        # UI層がData層を直接参照していないかチェック
        local data_refs=$(grep -E '(Repository|DataSource)Impl' "$file" 2>/dev/null || true)
        if [[ -n "$data_refs" ]]; then
            while IFS= read -r line; do
                violations+=("UI→Data:$line")
            done <<< "$data_refs"
        fi

        # UI層がDataディレクトリのファイルをimportしていないかチェック
        local data_imports=$(grep -E 'import.*Data\.' "$file" 2>/dev/null || true)
        if [[ -n "$data_imports" ]]; then
            while IFS= read -r line; do
                violations+=("UI→Data:$line")
            done <<< "$data_imports"
        fi
    fi

    if [[ "$file_layer" == "Domain" ]]; then
        # Domain層がUI層を参照していないかチェック
        local ui_refs=$(grep -E '(View|ViewModel|Screen)' "$file" 2>/dev/null | grep -v '//' || true)
        if [[ -n "$ui_refs" ]]; then
            while IFS= read -r line; do
                # SwiftUIのViewプロトコルは除外
                if [[ ! "$line" =~ "SwiftUI" ]] && [[ ! "$line" =~ ": View" ]]; then
                    violations+=("Domain→UI:$line")
                fi
            done <<< "$ui_refs"
        fi
    fi

    if [[ "$file_layer" == "Data" ]]; then
        # Data層がUI層を参照していないかチェック
        local ui_refs=$(grep -E '(ViewModel|Screen)' "$file" 2>/dev/null | grep -v '//' || true)
        if [[ -n "$ui_refs" ]]; then
            while IFS= read -r line; do
                violations+=("Data→UI:$line")
            done <<< "$ui_refs"
        fi
    fi

    if [[ "$file_layer" == "Model" ]]; then
        # Model層が他レイヤーを参照していないかチェック
        local layer_refs=$(grep -E '(UseCase|Repository|ViewModel|DataSource)' "$file" 2>/dev/null | grep -v '//' || true)
        if [[ -n "$layer_refs" ]]; then
            while IFS= read -r line; do
                violations+=("Model→Other:$line")
            done <<< "$layer_refs"
        fi
    fi

    printf '%s\n' "${violations[@]}" 2>/dev/null || true
}

# 依存関係の方向チェック
check_dependency_direction() {
    local file="$1"
    local file_layer=$(get_layer "$file")
    local violations=()

    # 具象クラスへの依存チェック
    if [[ "$file_layer" == "UI" ]] || [[ "$file_layer" == "Domain" ]]; then
        # Implで終わるクラスへの直接参照
        local impl_refs=$(grep -n 'Impl[^a-zA-Z]' "$file" 2>/dev/null | grep -v '//' || true)
        if [[ -n "$impl_refs" ]]; then
            while IFS= read -r line; do
                violations+=("具象依存:$line")
            done <<< "$impl_refs"
        fi
    fi

    printf '%s\n' "${violations[@]}" 2>/dev/null || true
}

# 対象ファイルの取得
get_target_files() {
    if [[ -n "$TARGET_DIR" ]]; then
        find "$TARGET_DIR" -name "*.swift" -type f 2>/dev/null
    else
        find "Package/Sources/AppFeature" -name "*.swift" -type f 2>/dev/null
    fi
}

# サマリー出力
output_summary() {
    echo "# レイヤー違反検出結果"
    echo ""
    echo "## アーキテクチャ構造"
    echo '```'
    echo "UI (View/ViewModel) → Domain (UseCase) → Data (Repository)"
    echo "                            ↑"
    echo "                        Model (Entity)"
    echo '```'
    echo ""

    local total_violations=0
    local ui_violations=0
    local domain_violations=0
    local data_violations=0
    local model_violations=0

    echo "## 検出した違反"
    echo ""

    while IFS= read -r file; do
        [[ -z "$file" ]] && continue

        local layer=$(get_layer "$file")
        local violations=$(analyze_imports "$file")
        local dep_violations=$(check_dependency_direction "$file")

        if [[ -n "$violations" ]] || [[ -n "$dep_violations" ]]; then
            echo "### $file ($layer層)"

            if [[ -n "$violations" ]]; then
                while IFS= read -r v; do
                    local type="${v%%:*}"
                    local detail="${v#*:}"
                    echo "- [$type] \`$detail\`"
                    ((total_violations++)) || true

                    case "$layer" in
                        UI) ((ui_violations++)) || true ;;
                        Domain) ((domain_violations++)) || true ;;
                        Data) ((data_violations++)) || true ;;
                        Model) ((model_violations++)) || true ;;
                    esac
                done <<< "$violations"
            fi

            if [[ -n "$dep_violations" ]]; then
                while IFS= read -r v; do
                    local type="${v%%:*}"
                    local detail="${v#*:}"
                    echo "- [$type] \`$detail\`"
                    ((total_violations++)) || true
                done <<< "$dep_violations"
            fi

            echo ""
        fi
    done < <(get_target_files)

    echo "## サマリー"
    echo ""
    echo "| レイヤー | 違反数 |"
    echo "|---------|--------|"
    echo "| UI層 | ${ui_violations}件 |"
    echo "| Domain層 | ${domain_violations}件 |"
    echo "| Data層 | ${data_violations}件 |"
    echo "| Model層 | ${model_violations}件 |"
    echo "| **合計** | **${total_violations}件** |"
    echo ""

    if [[ $total_violations -eq 0 ]]; then
        echo "✓ レイヤー違反は検出されませんでした"
    else
        echo "✗ ${total_violations}件のレイヤー違反が検出されました"
    fi
}

# JSON出力
output_json() {
    echo "{"
    echo '  "violations": ['

    local first=true
    while IFS= read -r file; do
        [[ -z "$file" ]] && continue

        local layer=$(get_layer "$file")
        local violations=$(analyze_imports "$file")
        local dep_violations=$(check_dependency_direction "$file")

        if [[ -n "$violations" ]] || [[ -n "$dep_violations" ]]; then
            [[ "$first" == true ]] || echo ","
            first=false

            echo "    {"
            echo "      \"file\": \"$file\","
            echo "      \"layer\": \"$layer\","
            echo '      "issues": ['

            local first_issue=true
            if [[ -n "$violations" ]]; then
                while IFS= read -r v; do
                    [[ "$first_issue" == true ]] || echo ","
                    first_issue=false
                    local type="${v%%:*}"
                    local detail="${v#*:}"
                    detail=$(echo "$detail" | sed 's/"/\\"/g')
                    echo -n "        {\"type\": \"$type\", \"detail\": \"$detail\"}"
                done <<< "$violations"
            fi

            if [[ -n "$dep_violations" ]]; then
                while IFS= read -r v; do
                    [[ "$first_issue" == true ]] || echo ","
                    first_issue=false
                    local type="${v%%:*}"
                    local detail="${v#*:}"
                    detail=$(echo "$detail" | sed 's/"/\\"/g')
                    echo -n "        {\"type\": \"$type\", \"detail\": \"$detail\"}"
                done <<< "$dep_violations"
            fi

            echo ""
            echo "      ]"
            echo -n "    }"
        fi
    done < <(get_target_files)

    echo ""
    echo "  ]"
    echo "}"
}

# メイン処理
main() {
    local total_violations=0

    case "$OUTPUT_FORMAT" in
        json)
            output_json
            ;;
        summary|*)
            # サマリー出力から違反数を取得
            local output=$(output_summary)
            echo "$output"
            # 合計行から件数を抽出
            total_violations=$(echo "$output" | grep -E "^\| \*\*合計\*\*" | sed -E 's/.*\*\*([0-9]+)件\*\*.*/\1/' || echo "0")
            ;;
    esac

    # 違反がある場合は終了コード1
    if [[ "$total_violations" -gt 0 ]]; then
        exit 1
    fi
    exit 0
}

main
