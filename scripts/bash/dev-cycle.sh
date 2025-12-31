#!/usr/bin/env bash
# 自律開発サイクルスクリプト
# 全AIエージェント共通で使用可能

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

REPO_ROOT=$(get_repo_root)
cd "$REPO_ROOT"

# 色付き出力
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

usage() {
    cat << EOF
Usage: $(basename "$0") <command> [options]

自律開発サイクルを実行します。

Commands:
  all           全サイクル実行（build → test → lint）
  build         ビルドエラーチェック
  test          テスト実行
  lint          Lint + レイヤー違反チェック
  status        現在の状態を確認

Note: セルフレビューはAI自身で実施してください

Options:
  -f, --fix     問題を検出したら終了コード1を返す（CIモード）
  -q, --quiet   最小限の出力
  -h, --help    このヘルプを表示

Examples:
  $(basename "$0") all              # 全サイクル
  $(basename "$0") build            # ビルドのみ
  $(basename "$0") review           # レビューのみ
  $(basename "$0") all --fix        # CIモード
EOF
    exit 0
}

# 引数
COMMAND=""
CI_MODE=false
QUIET=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        all|build|test|lint|status) COMMAND="$1"; shift ;;
        -f|--fix) CI_MODE=true; shift ;;
        -q|--quiet) QUIET=true; shift ;;
        -h|--help) usage ;;
        *) echo "Unknown: $1"; usage ;;
    esac
done

[[ -z "$COMMAND" ]] && usage

log() {
    [[ "$QUIET" == true ]] && return
    echo -e "$1"
}

log_header() {
    log "\n${BLUE}=== $1 ===${NC}\n"
}

log_success() {
    log "${GREEN}✓ $1${NC}"
}

log_warning() {
    log "${YELLOW}⚠ $1${NC}"
}

log_error() {
    log "${RED}✗ $1${NC}"
}

# ビルドチェック
run_build() {
    log_header "ビルドチェック"

    local result
    result=$("$SCRIPT_DIR/build.sh" 2>&1 | "$SCRIPT_DIR/extract-build-errors.sh" -o summary) || true

    local error_count=$(echo "$result" | grep -c "エラー:" | grep -v "0件" || echo "0")

    if echo "$result" | grep -q "エラー: [1-9]"; then
        log_error "ビルドエラーあり"
        echo "$result"
        return 1
    elif echo "$result" | grep -q "警告: [1-9]"; then
        log_warning "ビルド警告あり"
        [[ "$QUIET" == false ]] && echo "$result"
        return 0
    else
        log_success "ビルド成功"
        return 0
    fi
}

# テスト実行
run_test() {
    log_header "テスト実行"

    local result
    local exit_code=0

    result=$(xcodebuild test \
        -workspace ios-archi.xcworkspace \
        -scheme ios-archi \
        -destination 'platform=iOS Simulator,name=iPhone 16' \
        -only-testing:AppFeatureTests \
        2>&1) || exit_code=$?

    local test_failed=$(echo "$result" | grep -c "TEST.*FAILED" || echo "0")
    local test_passed=$(echo "$result" | grep -c "TEST.*PASSED" || echo "0")

    if [[ "$exit_code" -ne 0 ]] || [[ "$test_failed" -gt 0 ]]; then
        log_error "テスト失敗: ${test_failed}件"
        echo "$result" | grep -E "(Test Case|FAILED|error:)" | head -20
        return 1
    else
        log_success "テスト成功: ${test_passed}件"
        return 0
    fi
}

# レビュー実行（Lint + レイヤーチェックのみ。セルフレビューはAI自身で実施）
run_review() {
    local issues=0

    # レイヤー違反チェック
    log_header "レイヤー違反チェック"

    local layer_result
    layer_result=$("$SCRIPT_DIR/check-layer-violations.sh" 2>&1) || true

    local layer_issues=$(echo "$layer_result" | grep -c "違反" || echo "0")
    if [[ "$layer_issues" -gt 0 ]]; then
        log_warning "レイヤー違反: ${layer_issues}件"
        [[ "$QUIET" == false ]] && echo "$layer_result"
        ((issues += layer_issues))
    else
        log_success "レイヤー構造OK"
    fi

    # Lint
    log_header "SwiftLint"

    local lint_result
    lint_result=$(make lint 2>&1) || true

    local lint_errors=$(echo "$lint_result" | grep -c "error:" || echo "0")
    local lint_warnings=$(echo "$lint_result" | grep -c "warning:" || echo "0")

    if [[ "$lint_errors" -gt 0 ]]; then
        log_error "Lintエラー: ${lint_errors}件"
        ((issues += lint_errors))
    elif [[ "$lint_warnings" -gt 0 ]]; then
        log_warning "Lint警告: ${lint_warnings}件"
    else
        log_success "Lint OK"
    fi

    if [[ "$issues" -gt 0 ]]; then
        return 1
    fi
    return 0
}

# ステータス確認
run_status() {
    log_header "プロジェクト状態"

    echo "Git状態:"
    git status --short

    echo ""
    echo "変更ファイル:"
    git diff --name-only 2>/dev/null | head -10
}

# 全サイクル実行
run_all() {
    local failed=false

    run_build || failed=true

    if [[ "$failed" == false ]]; then
        run_test || failed=true
    fi

    run_review || failed=true

    log_header "サイクル完了"

    if [[ "$failed" == true ]]; then
        log_error "問題が検出されました"
        return 1
    else
        log_success "全チェック通過"
        return 0
    fi
}

# メイン
main() {
    local exit_code=0

    case "$COMMAND" in
        all) run_all || exit_code=1 ;;
        build) run_build || exit_code=1 ;;
        test) run_test || exit_code=1 ;;
        lint) run_review || exit_code=1 ;;
        status) run_status ;;
    esac

    if [[ "$CI_MODE" == true ]]; then
        exit $exit_code
    fi
}

main
