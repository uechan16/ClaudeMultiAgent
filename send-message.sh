#!/bin/bash

# 🤖 喫茶店「Claude」 - メッセージ送信システム

# スクリプトのディレクトリを取得（submodule対応）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 使用方法表示
show_usage() {
    cat << EOF
☕ 喫茶店「Claude」 メッセージ送信システム

使用方法:
  $0 [スタッフ名] [メッセージ]
  $0 --list

利用可能スタッフ:
  ceo     - マスター（オーナー）
  manager - 店長
  dev1    - バイト（フロントエンド得意）
  dev2    - バイト（バックエンド得意）
  dev3    - バイト（リサーチ得意）
  qa      - バイト（品質チェック担当）
  observer - 監視者（WatchMan飯田）

使用例:
  $0 manager "新しいオーダーを開始してください"
  $0 dev1 "フロントエンドの実装をお願いします"
EOF
}

# スタッフ一覧表示
show_agents() {
    echo "☕ 喫茶店「Claude」スタッフ一覧:"
    echo "=============================="
    echo "  ceo     → ceo:0        (マスター)"
    echo "  manager → team:0.0     (店長)"
    echo "  dev1    → team:0.1     (バイト・フロントエンド得意)"
    echo "  dev2    → team:0.2     (バイト・バックエンド得意)"
    echo "  dev3    → team:0.3     (バイト・リサーチ得意)"
    echo "  qa      → team:0.4     (バイト・品質チェック担当)"
    echo "  observer→ observer:0   (監視者・WatchMan飯田)"
    echo "=============================="
}

# ログ機能
log_message() {
    local agent="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    mkdir -p "$SCRIPT_DIR/logs"
    echo "[$timestamp] → $agent: \"$message\"" >> "$SCRIPT_DIR/logs/communication.log"
}

# セッション存在確認
check_session() {
    local session_name="$1"
    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        echo "❌ エラー: セッション '$session_name' が見つかりません"
        echo "先に $SCRIPT_DIR/start-ai-team.sh を実行してください"
        return 1
    fi
    return 0
}

# 改良版メッセージ送信
send_enhanced_message() {
    local target="$1"
    local message="$2"
    local agent_name="$3"

    echo "📤 送信中: $agent_name へメッセージを送信..."

    # 1. プロンプトクリア（より確実に）
    tmux send-keys -t "$target" C-c
    sleep 0.4

    # 2. 追加のクリア（念のため）
    tmux send-keys -t "$target" C-u
    sleep 0.2

    # 3. メッセージ送信
    tmux send-keys -t "$target" "$message"
    sleep 0.3

    # 4. Enter押下（自動実行）
    tmux send-keys -t "$target" C-m
    sleep 0.5

    echo "✅ 送信完了: $agent_name に自動実行されました"
}

# メイン処理
main() {
    # 引数チェック
    if [[ $# -eq 0 ]]; then
        show_usage
        exit 1
    fi

    # --listオプション
    if [[ "$1" == "--list" ]]; then
        show_agents
        exit 0
    fi

    if [[ $# -lt 2 ]]; then
        show_usage
        exit 1
    fi

    local agent="$1"
    local message="$2"

    # 送信先の決定
    local session=""
    local pane=""
    local target=""

    case $agent in
        "ceo")
            session="ceo"
            pane="0"
            target="ceo:0"
            ;;
        "manager")
            session="team"
            pane="0.0"
            target="team:0.0"
            ;;
        "dev1")
            session="team"
            pane="0.1"
            target="team:0.1"
            ;;
        "dev2")
            session="team"
            pane="0.2"
            target="team:0.2"
            ;;
        "dev3")
            session="team"
            pane="0.3"
            target="team:0.3"
            ;;
        "qa")
            session="team"
            pane="0.4"
            target="team:0.4"
            ;;
        "observer")
            session="observer"
            pane="0"
            target="observer:0"
            ;;
        *)
            echo "❌ エラー: 不明なスタッフ名 '$agent'"
            show_agents
            exit 1
            ;;
    esac

    # セッション存在確認
    if ! check_session "$session"; then
        exit 1
    fi

    # メッセージ送信
    send_enhanced_message "$target" "$message" "$agent"

    if [ "$agent" != "observer" ]; then
        # observerにもログ送信
        send_enhanced_message "observer:0" "宛先: $agent ($target) : $message" "observer"
    fi

    # ログ記録
    log_message "$agent" "$message"

    echo ""
    echo "🎯 メッセージ詳細:"
    echo "   宛先: $agent ($target)"
    echo "   内容: \"$message\""
    echo "   ログ: $SCRIPT_DIR/logs/communication.log に記録済み"

    return 0
}

main "$@"
