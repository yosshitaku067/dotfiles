#!/bin/bash
set -e

echo "🚀 Starting Setup..."

# --- 1. システムパッケージ (apt) ---
echo "📦 Installing System Packages..."
sudo apt update
sudo apt install -y zsh unzio curl git libatomic1

# --- 2. シェルの変更 ---
if [[ "$SHELL" != *"zsh"* ]]; then
    echo "🔄 Changing default shell to Zsh..."
    sudo usermod -s $(which zsh) $USER
    echo "⚠️  Log out and back in for shell change to take effect."
fi

# --- 3. Mise (ツール管理) ---
if ! command -v mise >/dev/null 2>&1; then
    echo "📦 Installing Mise..."
    curl https://mise.run | sh
    export PATH="$HOME/.local/bin:$PATH"
fi

# --- 4. Chezmoi (dotfiles管理)---
if ! command -v chezmoi >/dev/null 2>&1; then
    echo "📦 Installing Chezmoi via mise..."
    mise use -g chezmoi@latest
fi

# --- 5. Dotfilesの展開 ---
echo "🔧 Applying dotfiles via Chezmoi..."
mise exec chezmoi -- chezmoi init --apply --source="$HOME/dotfiles"

# --- 6. ツールのインストール ---
echo "⬇️  Installing tools via Mise..."
# config.toml に書かれたツール(Sheldon含む)を一括インストール
mise install --yes

echo "🎉 Setup Complete! Please restart your shell."