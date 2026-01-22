#!/bin/bash
set -e

echo "🚀 Starting Setup..."

# --- 1. システムパッケージ (apt) ---
echo "📦 Installing System Packages..."
sudo apt update
sudo apt install -y zsh unzip curl git libatomic1

# --- 2. WSL Utilities ---
if grep -q -i "microsoft" /proc/version; then
    echo "🐧 Installing WSL Utilities..."
    sudo apt install -y wslu
fi

# --- 3. シェルの変更 ---
if [[ "$SHELL" != *"zsh"* ]]; then
    echo "🔄 Changing default shell to Zsh..."
    sudo usermod -s $(which zsh) $USER
    echo "⚠️  Log out and back in for shell change to take effect."
fi

# --- 4. Mise (ツール管理) ---
if ! command -v mise >/dev/null 2>&1; then
    echo "📦 Installing Mise..."
    curl https://mise.run | sh
    export PATH="$HOME/.local/bin:$PATH"
fi

# --- 5. Chezmoi (dotfiles管理)---
if ! command -v chezmoi >/dev/null 2>&1; then
    echo "📦 Installing Chezmoi via mise..."
    mise use -g chezmoi@latest
fi

# --- 6. Dotfilesの展開 ---
echo "🔧 Applying dotfiles via Chezmoi..."
mise exec chezmoi -- chezmoi init --apply --force --source="$HOME/dotfiles"

# --- 7. ツールのインストール ---
echo "⬇️  Installing tools via Mise..."
# config.toml に書かれたツール(Sheldon含む)を一括インストール
mise install --yes

# --- 7. Syncing mise changes back to chezmoi ---
echo "🔄 Syncing potential mise config changes back to chezmoi..."
mise exec chezmoi -- chezmoi add ~/.config/mise/config.toml

echo "🎉 Setup Complete! Please restart your shell."