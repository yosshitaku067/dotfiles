#!/bin/bash
set -e

echo "🚀 Starting Setup..."

# --- 1. システムパッケージ (apt) ---
if ! command -v zsh >/dev/null 2>&1; then
    echo "📦 Installing System Packages..."
    sudo apt update
    sudo apt install -y zsh stow unzip curl git
fi

# --- 2. シェルの変更 ---
if [[ "$SHELL" != *"zsh"* ]]; then
    echo "🔄 Changing default shell to Zsh..."
    chsh -s $(which zsh)
    echo "⚠️  Log out and back in for shell change to take effect."
fi

# --- 3. Mise (ツール管理) ---
if ! command -v mise >/dev/null 2>&1; then
    echo "📦 Installing Mise..."
    curl https://mise.run | sh
    export PATH="$HOME/.local/bin:$PATH"
fi

# --- 4. Dotfilesのリンク (Stow) ---
echo "🔗 Linking dotfiles..."
mkdir -p "$HOME/.config"

# Dotfilesディレクトリへ移動
cd "$HOME/dotfiles"

# 基本設定をリンク (競合時は dotfiles 側のファイルを正とする --adopt オプション付き)
stow --adopt -v mise zsh git

# Sheldon設定は特殊配置なので手動リンク
echo "🔗 Linking Sheldon config..."
mkdir -p "$HOME/.config/sheldon"
# -f (force) で上書きリンク
ln -sf "$HOME/dotfiles/sheldon/plugins.toml" "$HOME/.config/sheldon/plugins.toml"

# Starship設定の手動リンク
echo "🔗 Linking Starship config..."
# dotfiles側にファイルがある場合のみリンクを作成
if [ -f "$HOME/dotfiles/starship/starship.toml" ]; then
    ln -sf "$HOME/dotfiles/starship/starship.toml" "$HOME/.config/starship.toml"
fi

# Gitの変更をリセット（--adoptで差分が出た場合のため）
git checkout . 2>/dev/null || true

# --- 5. ツールのインストール ---
echo "⬇️  Installing tools via Mise..."
# config.toml に書かれたツール(Sheldon含む)を一括インストール
mise install --yes

echo "🎉 Setup Complete! Please restart your shell."