# 喫茶店「Claude」 - マルチエージェント開発システム

Claude Codeを使った階層型マルチエージェントシステムです。喫茶店のスタッフに見立てた複数のAIエージェントが協調して開発タスクを遂行します。

## スタッフ構成

```
        お客様（ユーザー）
              │
        ☕ マスター（CEO）
              │
        👔 店長 佐々木（Manager）
        ┌─────┼─────┬─────┐
        │     │     │     │
   🎨 田中くん 🖥️ 山本さん 🔍 小林くん 📋 鈴木さん
     (dev1)    (dev2)    (dev3)    (QA)
   フロントエンド バックエンド リサーチ  品質チェック
        │
   👁️ WatchMan飯田（Observer）
      全体監視・記録
```

| 役職 | 名前 | 役割 |
|-----|------|------|
| マスター | - | オーナー。方針決定と最終承認 |
| 店長 | 佐々木 | プロジェクト管理、タスク配分 |
| バイト | 田中くん | 開発全般（フロントエンド得意） |
| バイト | 山本さん | 開発全般（バックエンド得意） |
| バイト | 小林くん | 開発全般（リサーチ得意） |
| バイト | 鈴木さん | 品質チェック担当 |
| 監視者 | WatchMan飯田 | 全体監視・ストーリーテリング |

## 必要環境

- [Claude Code CLI](https://claude.ai/code)
- tmux
- bash

## セットアップ

### 1. submoduleとして追加（推奨）

```bash
cd your-project
git submodule add https://github.com/uechan16/ClaudeMultiAgent.git
```

### 2. 単独で使用

```bash
git clone https://github.com/uechan16/ClaudeMultiAgent.git
cd ClaudeMultiAgent
```

## 使い方

### 開店（システム起動）

親リポジトリのルートで実行：

```bash
./ClaudeMultiAgent/start-ai-team.sh
```

起動後、3つのtmuxセッションが作成されます：
- `ceo` - マスター用
- `team` - 店長とバイト用（5分割）
- `observer` - 監視者用

### スタッフの初期化

```bash
./ClaudeMultiAgent/initialize-agents.sh
```

### 画面への接続

```bash
# マスター画面
tmux attach -t ceo

# チーム画面（店長・バイト）
tmux attach -t team

# 監視者画面
tmux attach -t observer
```

### 画面操作

| キー | 動作 |
|-----|------|
| `Ctrl+B` → `↑↓←→` | ペイン移動 |
| `Ctrl+B` → `d` | デタッチ（終了せず離脱） |

### オーダーの出し方

マスター画面に接続後、メッセージを入力：

```
【プロジェクト開始指示】
プロジェクト名：シンプルTodoアプリ
目標：基本的なタスク管理機能を持つWebアプリ
要件：タスク追加・削除・完了機能、レスポンシブデザイン
期限：1時間以内
このプロジェクトを成功させてください。
```

### 閉店（システム終了）

```bash
tmux kill-server
```

## ディレクトリ構成

```
親リポジトリ/                      ← 作業ディレクトリ
├── .claude/skills/                ← Skills保存先
├── src/                           ← プロジェクトのソースコード
└── ClaudeMultiAgent/            ← このsubmodule
    ├── start-ai-team.sh           # 起動スクリプト
    ├── initialize-agents.sh       # 初期化スクリプト
    ├── send-message.sh            # メッセージ送信
    ├── ceo-command.sh             # マスター用コマンドヘルパー
    ├── instructions/              # 各スタッフの指示書
    │   ├── ceo.md                 # マスター
    │   ├── manager.md             # 店長
    │   ├── dev1.md                # 田中くん
    │   ├── dev2.md                # 山本さん
    │   ├── dev3.md                # 小林くん
    │   ├── qa.md                  # 鈴木さん
    │   ├── observer.md            # WatchMan飯田
    │   └── names.md               # スタッフ名簿・履歴
    ├── logs/                      # 通信ログ
    └── .claude/skills/            # チーム用Skills
```

## 環境変数

起動時に以下の環境変数が設定されます：

| 変数 | 内容 |
|-----|------|
| `CLAUDE_TEAM_DIR` | submoduleの絶対パス |

## コマンド

### send-message.sh

スタッフ間でメッセージを送信します。

```bash
send-message.sh [スタッフ名] "メッセージ"
```

利用可能なスタッフ名：
- `ceo` - マスター
- `manager` - 店長
- `dev1` - 田中くん
- `dev2` - 山本さん
- `dev3` - 小林くん
- `qa` - 鈴木さん
- `observer` - WatchMan飯田

例：
```bash
send-message.sh manager "進捗を報告してください"
send-message.sh dev1 "フロントエンドの実装をお願いします"
```

## 機能

### Skills提案

バイトは繰り返し作業をSkillとして提案できます。

```
バイト → 【Skill提案】 → 店長
                          ↓
              【Skill登録稟議】 → マスター
                          ↓
                     承認 → 登録
```

### 解雇・再採用

パフォーマンスに問題があるスタッフは解雇し、新しいスタッフを採用できます。

```
店長 → 【バイト解雇稟議】 → マスター
                            ↓
                       承認 → 解雇
                            ↓
              instructions改善 + 名前変更
                            ↓
                       新バイト採用
```

解雇履歴は `instructions/names.md` に記録されます。

## ワークフロー

```
1. マスターがオーダーを受ける
2. マスター → 店長に指示
3. 店長 → バイトにタスク配分
4. バイト → 作業実行
5. バイト → 店長に【完了報告】
6. 全作業完了 → 店長 → 鈴木さんに品質検証依頼
7. 鈴木さん → 検証・修正
8. 鈴木さん → 店長に【QA承認完了】
9. 店長 → マスターに【プロジェクト完了報告】
10. マスター → 承認 → お客様に報告
```

## カスタマイズ

### スタッフの得意分野を変更

`instructions/dev1.md`、`dev2.md`、`dev3.md` を編集して得意分野を変更できます。

### 新しいスタッフを追加

1. `instructions/` に新しいmdファイルを作成
2. `start-ai-team.sh` にtmuxペインを追加
3. `send-message.sh` にスタッフを追加
4. `instructions/names.md` に追記

## トラブルシューティング

### セッションが見つからない

```bash
# セッション一覧を確認
tmux ls

# 再起動
tmux kill-server
./ClaudeMultiAgent/start-ai-team.sh
```

### メッセージが送信されない

```bash
# セッション存在確認
tmux has-session -t team && echo "OK" || echo "Not found"

# 手動でペインにメッセージ送信
tmux send-keys -t team:0.0 "テストメッセージ" C-m
```

## ライセンス

MIT
