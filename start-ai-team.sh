#!/bin/bash

# 既存のセッションをクリーンアップ
tmux kill-session -t ceo 2>/dev/null
tmux kill-session -t observer 2>/dev/null 
tmux kill-session -t team 2>/dev/null


# 監視者セッション（単独画面）
tmux new-session -d -s observer
tmux send-keys -t observer "cd $(pwd)" C-m
tmux send-keys -t observer "claude --dangerously-skip-permissions instructions/observer.md" C-m

sleep 2

# CEOセッション（単独画面）
tmux new-session -d -s ceo
tmux send-keys -t ceo "cd $(pwd)" C-m
tmux send-keys -t ceo "claude --dangerously-skip-permissions instructions/ceo.md" C-m

# チームセッション（4分割）
tmux new-session -d -s team

# 2x2のグリッド作成
tmux split-window -h -t team
tmux split-window -v -t team:0.0
tmux split-window -v -t team:0.1
tmux split-window -v -t team:0.3


# 各画面に移動してClaude起動（対応するmdファイル指定）
# team:0.0 = manager
tmux send-keys -t team:0.0 "cd $(pwd)" C-m
tmux send-keys -t team:0.0 "claude --dangerously-skip-permissions instructions/manager.md" C-m

# team:0.1 = dev1
tmux send-keys -t team:0.1 "cd $(pwd)" C-m
tmux send-keys -t team:0.1 "claude --dangerously-skip-permissions instructions/developer.md" C-m

# team:0.2 = dev2
tmux send-keys -t team:0.2 "cd $(pwd)" C-m
tmux send-keys -t team:0.2 "claude --dangerously-skip-permissions instructions/developer.md" C-m

# team:0.3 = dev3
tmux send-keys -t team:0.3 "cd $(pwd)" C-m
tmux send-keys -t team:0.3 "claude --dangerously-skip-permissions instructions/developer.md" C-m

# team:0.4 = qa
tmux send-keys -t team:0.4 "cd $(pwd)" C-m
tmux send-keys -t team:0.4 "claude --dangerously-skip-permissions instructions/qa.md" C-m

echo "AI並列開発システムを起動しました！"
echo ""
echo "使い方："
echo "・CEO画面に接続: tmux attach -t ceo"
echo "・チーム画面に接続: tmux attach -t team"
echo "・監視者画面に接続: tmux attach -t observer"
echo ""
echo "画面操作："
echo "・Ctrl+B → ↑↓←→で画面移動"
echo "・Ctrl+B → dでデタッチ（終了ではない）"
echo "・tmux kill-server で完全終了" 
