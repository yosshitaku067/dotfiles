# Dotfiles

[English](../README.md) | **日本語**

## 概要

開発環境構築用の個人 dotfiles リポジトリ。
Zsh をベースに、各種ツールのバージョンやプラグインの管理を自動化し、どこでも一貫したモダンな CLI 環境を再現することを目的とする。

管理には [Chezmoi](https://www.chezmoi.io/) を使用し、`~/dotfiles` にクローンして展開する想定。

Debian 系であればどの環境でも動作するように設計されており、ネイティブ Linux、WSL2、Debian ベースの [Dev Container](https://containers.dev/) のいずれでも利用できる。

## 主な特徴

- **シェル**: Zsh をデフォルトシェルとして使用。
- **プロンプト**: [Starship](https://starship.rs/) によるモダンで情報量の多いプロンプト。
- **ツール管理**: [Mise](https://mise.jdx.dev/) で CLI ツールのバージョンを管理。
- **プラグイン管理**: [Sheldon](https://sheldon.cli.rs/) で Zsh プラグインを管理。
- **ファジー検索**: [fzf](https://github.com/junegunn/fzf) と [fzf-tab](https://github.com/Aloxaf/fzf-tab) による強力な補完機能。
- **DX 向上**: エイリアス、アブリビエーション、シンタックスハイライト、自動補完、矢印キーによる履歴部分一致検索。
- **Claude Code 連携**: [Claude Code](https://claude.com/claude-code) 向けのカスタムステータスライン、設定マージロジック、個人コーディング規約を同梱。
- **Debian 系環境を横断的にサポート**: ネイティブ Debian/Ubuntu、WSL2（Windows ブラウザシムを自動生成）、Debian ベース Dev Container のいずれでも動作する。

## `mise` で管理しているツール

`config.toml` に記載されている主要なツール。`mise install` でまとめてインストールされる。

- `bat`: `cat` の代替。
- `eza`: `ls` のモダンな代替。
- `fzf`: コマンドラインのファジーファインダー。
- `gh`: GitHub CLI。
- `starship`: クロスシェルプロンプト。
- `zoxide`: スマートな `cd`。
- `chezmoi`: dotfiles マネージャ。
- `delta`: `git diff` ビューア。
- `ripgrep`, `fd`, `jq`, `dust`, `zellij`, `sheldon`, `cargo-binstall`, `usage`: 汎用 CLI ユーティリティ。
- `node`, `python`, `rust`, `golang` などの言語ランタイム。

### ツールバージョンの更新

`dot_config/mise/config.toml` のツールバージョンは再現性のためにすべてピン留めされている。

- 新しいバージョンの確認: `mise outdated`
- ピンを一括で更新: `mise outdated --bump`
- 手動で更新する場合: `dot_config/mise/config.toml` のバージョンを編集して `mise install`

## `sheldon` で管理している Zsh プラグイン

`plugins.toml` に記載されている主要なプラグイン。

- `zsh-defer`: プラグインの遅延ロードによりシェル起動を高速化。
- `zsh-autosuggestions`: 履歴を元にコマンド候補を表示。
- `zsh-completions`: 多くのコマンドに対する追加補完定義。
- `fzf-tab`: `fzf` を使ったインタラクティブなタブ補完。
- `zsh-abbr`: よく使うコマンドのアブリビエーション定義。
- `zsh-history-substring-search`: 部分一致による履歴検索。
- `zsh-syntax-highlighting`: コマンドラインのシンタックスハイライト。

### プラグインバージョンの更新

`dot_config/sheldon/plugins.toml` の各プラグインは再現性のため `rev = "..."` でコミット SHA を固定している。末尾のコメントには基準となる直近の上流タグを記載している。

1. 対象コミットの SHA を取得:
   - リリースタグから: `git ls-remote https://github.com/<owner>/<repo> refs/tags/<tag>`
   - 既定ブランチの最新: `git ls-remote https://github.com/<owner>/<repo> HEAD`
   - GitHub CLI 経由: `gh api repos/<owner>/<repo>/commits/<tag-or-branch> --jq .sha`
2. `plugins.toml` の `rev = "..."` と直近タグのコメントを書き換える。
3. `chezmoi apply` で `~/.config/sheldon/plugins.toml` に反映する。
4. `sheldon lock --update` を実行して新リビジョンを再取得し、`~/.local/share/sheldon/plugins.lock` を更新する。

## シェルのエイリアス・関数・キーバインド

`dot_zshenv` と `dot_zshrc` で定義。

### エイリアス
- `cat` → `bat` （`bat` が無い場合は `cat` にフォールバック）。
- `ls` → `eza --icons --git`、`ll` → `eza -l --icons --git`。
- `g` → `git`。
- `dot` → `code ~/dotfiles` （VS Code で dotfiles リポジトリを開く）。

### 関数
- `lcurl`: `curl` を `localhost` 限定に制限。意図しないホストへのリクエストを防ぐ。
- `dcurl`: `curl` を `host.docker.internal` 限定に制限。コンテナ内から Docker ホスト上のサービスを叩く際の補助関数。

### キーバインド・補完
- 上下矢印キーが `zsh-history-substring-search` にバインドされており、部分一致で履歴を辿れる。
- fzf-tab のプレビューは `cd`（`eza` によるディレクトリ表示）と `git checkout/switch/branch`（ブランチプレビュー付きのグラフログ）に設定済み。

## Claude Code 連携

このリポジトリには、Claude Code の設定一式が同梱されている。`install.sh` から Claude Code 公式の native installer も呼ばれる。

- **`private_dot_claude/CLAUDE.md`**: 個人グローバル指示（回答言語、命名規約、TypeScript ルール、ブランチ管理方針）。
- **`private_dot_claude/executable_status-line.js`**: モデル名、カレントディレクトリ、git ブランチ、累積トークン使用量（圧縮しきい値ベースの配色付き）、セッションコスト（USD）を表示するカスタムステータスライン。
- **`.chezmoitemplates/claude-settings-base.json`**: `statusLine`、`plugins`、`permissions`（allow/deny/ask）、`attribution`、環境変数を含むベース設定テンプレート。
- **`private_dot_claude/modify_settings.json.tmpl`**: 既存の `~/.claude/settings.json` にベース設定を `jq` でマージする chezmoi `modify_` テンプレート。`statusLine` や `env` などの既知キーは dotfiles 側を優先し、`permissions.allow / deny / ask` は UI 経由で追加されたルールを保持するためにユニオン結合する。

## サポート環境

ホストが Debian 系であれば環境に依存しない構成になっており、`install.sh` は以下のいずれでも同じように利用できる。

### ネイティブ Debian / Ubuntu
そのまま動作する。特別な処理は無い。

### WSL2
`install.sh` が `/proc/version` 経由で WSL2 を検知すると以下を行う。

- `~/.local/bin/xdg-open` ラッパーを生成し、`rundll32 url.dll,FileProtocolHandler` 経由で Windows の既定ブラウザに委譲する。
- `dot_zshenv` が `$BROWSER` を同じハンドラに設定するため、`$BROWSER` を直接読む CLI ツールも問題なく動作する。

### Debian ベース Dev Container
`devcontainer.json` の `postCreateCommand` などから呼び出す利用を想定。コンテナ自体がすでに Debian なので、WSL2 用シムは生成されない。`dcurl` 関数（`curl` を `host.docker.internal` 限定に絞り込むヘルパ）は、コンテナ内から Docker ホスト上のサービスを叩く際に有用。

## インストール

このリポジトリは Debian 系の Linux ディストリビューションを想定している。

### 前提条件
- Debian / Ubuntu などの `apt-get` ベースのディストリビューション。`install.sh` は `apt-get` が利用できない場合は即座に終了する。ネイティブ Linux、WSL2、Debian ベースの Dev Container を含む。
- オプション: WSL2 — 検知された場合はブラウザ関連のシムが自動的にインストールされる。
- スクリプトは冪等。すべてのツールインストールは `command -v` でガードされているため、再実行しても安全（Dev Container の rebuild にも適している）。

### 手順

1.  **リポジトリをクローン**
    ```bash
    git clone https://github.com/<YOUR_USERNAME>/dotfiles.git ~/dotfiles
    ```

2.  **インストールスクリプトを実行**
    `install.sh` を実行する。これにより、必要な apt パッケージのインストール、`mise` と `chezmoi` のセットアップ、dotfiles の適用、`mise` 管理ツールのインストール、Claude Code native installer の実行が行われる。

    ```bash
    cd ~/dotfiles
    ./install.sh
    ```

3.  **シェルを再起動**
    インストール完了後、シェルを再起動（または再ログイン）する。

## ディレクトリ構成

このリポジトリは [chezmoi の命名規約](https://www.chezmoi.io/reference/source-state-attributes/) に従い、ファイル名・ディレクトリ名のプレフィックスで配置方法が決まる。

- `dot_*`: ホームディレクトリ直下のドットファイルになる（例: `dot_zshrc` → `~/.zshrc`）。
- `dot_config/`: `~/.config/` 配下に展開される。
  - `mise/config.toml`: `mise` で管理するツール一覧。
  - `sheldon/plugins.toml`: `sheldon` で管理するプラグイン一覧。
  - `starship.toml`: プロンプトの設定。
  - `git/ignore`: グローバル gitignore（`**/.claude/settings.local.json` などを除外）。
- `private_*`: パーミッション `0600` で配置される。
  - `private_dot_claude/`: Claude Code の設定（`CLAUDE.md`、`status-line.js`、設定マージテンプレート）。
- `executable_*`: 実行権限を付与して配置される（例: `executable_status-line.js`）。
- `*.tmpl`: chezmoi テンプレート。適用時にレンダリングされる。`modify_*.tmpl` は既存のターゲットファイルを上書きではなく変換する特殊形式（Claude Code 設定のマージで使用）。
- `.chezmoitemplates/`: `*.tmpl` から参照される再利用可能なテンプレート断片。
- `.chezmoiignore`: ホームディレクトリに展開してほしくないファイル（例: `install.sh`、`README.md`、`docs/`）。
- `docs/`: ドキュメント（このファイルなど）。chezmoi の展開対象外。
- `install.sh`: セットアップスクリプト。
