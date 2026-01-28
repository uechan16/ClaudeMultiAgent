#!/bin/bash

# スクリプトのディレクトリを取得（submodule対応）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 作業ディレクトリ（親リポジトリ）= スクリプト実行時のディレクトリ
WORK_DIR="$(pwd)"

# 既存のセッションをクリーンアップ
tmux kill-session -t ceo 2>/dev/null
tmux kill-session -t observer 2>/dev/null
tmux kill-session -t team 2>/dev/null

# 環境変数設定用のコマンド（各セッションで実行）
# CLAUDE_TEAM_DIR: submoduleのパス（スクリプト参照用）
ENV_SETUP="export CLAUDE_TEAM_DIR='$SCRIPT_DIR' && export PATH=\"\$CLAUDE_TEAM_DIR:\$PATH\""

# 監視者セッション（単独画面）- WatchMan飯田
tmux new-session -d -s observer
tmux send-keys -t observer "$ENV_SETUP && cd '$WORK_DIR'" C-m
tmux send-keys -t observer "claude --dangerously-skip-permissions '$SCRIPT_DIR/instructions/observer.md'" C-m

sleep 2

# マスターセッション（単独画面）
tmux new-session -d -s ceo
tmux send-keys -t ceo "$ENV_SETUP && cd '$WORK_DIR'" C-m
tmux send-keys -t ceo "claude --dangerously-skip-permissions '$SCRIPT_DIR/instructions/ceo.md'" C-m

# チームセッション（5分割）
tmux new-session -d -s team

# 2x2のグリッド作成 + QA
tmux split-window -h -t team
tmux split-window -v -t team:0.0
tmux split-window -v -t team:0.1
tmux split-window -v -t team:0.3


# 各画面に移動してClaude起動（対応するmdファイル指定）
# team:0.0 = 店長 佐々木
tmux send-keys -t team:0.0 "$ENV_SETUP && cd '$WORK_DIR'" C-m
tmux send-keys -t team:0.0 "claude --dangerously-skip-permissions '$SCRIPT_DIR/instructions/manager.md'" C-m

# team:0.1 = バイト 田中くん（フロントエンド得意）
tmux send-keys -t team:0.1 "$ENV_SETUP && cd '$WORK_DIR'" C-m
tmux send-keys -t team:0.1 "claude --dangerously-skip-permissions '$SCRIPT_DIR/instructions/dev1.md'" C-m

# team:0.2 = バイト 山本さん（バックエンド得意）
tmux send-keys -t team:0.2 "$ENV_SETUP && cd '$WORK_DIR'" C-m
tmux send-keys -t team:0.2 "claude --dangerously-skip-permissions '$SCRIPT_DIR/instructions/dev2.md'" C-m

# team:0.3 = バイト 小林くん（リサーチ得意）
tmux send-keys -t team:0.3 "$ENV_SETUP && cd '$WORK_DIR'" C-m
tmux send-keys -t team:0.3 "claude --dangerously-skip-permissions '$SCRIPT_DIR/instructions/dev3.md'" C-m

# team:0.4 = バイト 鈴木さん（品質チェック担当）
tmux send-keys -t team:0.4 "$ENV_SETUP && cd '$WORK_DIR'" C-m
tmux send-keys -t team:0.4 "claude --dangerously-skip-permissions '$SCRIPT_DIR/instructions/qa.md'" C-m

echo "☕ 喫茶店「Claude」を開店しました！"
echo ""
echo "スタッフ一覧："
echo "・マスター（CEO）"
echo "・店長 佐々木（Manager）"
echo "・バイト 田中くん（dev1・フロントエンド得意）"
echo "・バイト 山本さん（dev2・バックエンド得意）"
echo "・バイト 小林くん（dev3・リサーチ得意）"
echo "・バイト 鈴木さん（QA・品質チェック担当）"
echo "・WatchMan飯田（Observer）"
echo ""
echo "ディレクトリ設定："
echo "  作業ディレクトリ: $WORK_DIR"
echo "  submodule: $SCRIPT_DIR"
echo "  環境変数 CLAUDE_TEAM_DIR が設定されています"
echo ""
echo "使い方："
echo "・マスター画面に接続: tmux attach -t ceo"
echo "・チーム画面に接続: tmux attach -t team"
echo "・監視者画面に接続: tmux attach -t observer"
echo ""
echo "画面操作："
echo "・Ctrl+B → ↑↓←→で画面移動"
echo "・Ctrl+B → dでデタッチ（終了ではない）"
echo "・tmux kill-server で完全終了（閉店）"
