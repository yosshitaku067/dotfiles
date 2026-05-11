#!/bin/bash
set -e

# Debian 系（apt-get 利用可能）のみサポート
command -v apt-get >/dev/null || { echo "apt-get required (Debian系)" >&2; exit 1; }

echo "🚀 Starting Setup..."

# --- 1. システムパッケージ (apt) ---
echo "📦 Installing System Packages..."
sudo apt update
sudo apt install -y zsh unzip curl git libatomic1 xdg-utils

# --- 2. WSL2 ブラウザ連携 ---
# wslu は upstream が deprecated を宣言しているため使用しない。
# 代わりに xdg-utils（Step 1 で導入済み）の xdg-open を ~/.local/bin のラッパーで上書きする。
if grep -q -i "microsoft" /proc/version 2>/dev/null; then
    echo "🌐 Setting up xdg-open wrapper for WSL2..."
    mkdir -p "$HOME/.local/bin"
    cat <<'EOF' > "$HOME/.local/bin/xdg-open"
#!/bin/sh
# WSL2 から Windows のデフォルトブラウザ／関連付けアプリを開くためのラッパー
exec /mnt/c/Windows/System32/rundll32.exe url.dll,FileProtocolHandler "$1"
EOF
    chmod +x "$HOME/.local/bin/xdg-open"
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
    curl -fsSL https://mise.run | sh
    export PATH="$HOME/.local/bin:$PATH"
fi

# --- 5. Chezmoi (dotfiles管理)---
if ! command -v chezmoi >/dev/null 2>&1; then
    echo "📦 Installing Chezmoi via mise..."
    mise use -g chezmoi@latest
fi

# --- 6. Chezmoiソースディレクトリのセットアップ ---
CHEZMOI_SOURCE_DIR="$HOME/.local/share/chezmoi"
# 実ディレクトリだとユーザーデータごと消えるので拒否する
if [ -e "$CHEZMOI_SOURCE_DIR" ] && [ ! -L "$CHEZMOI_SOURCE_DIR" ]; then
    echo "❌ $CHEZMOI_SOURCE_DIR は実ディレクトリです。手動で退避してから再実行してください。" >&2
    exit 1
fi
# シンボリックリンクの指す先が想定と異なる場合のみ作り直す
if [ "$(readlink "$CHEZMOI_SOURCE_DIR" 2>/dev/null)" != "$HOME/dotfiles" ]; then
    echo "🔗 Setting up Chezmoi source directory..."
    rm -f "$CHEZMOI_SOURCE_DIR"
    mkdir -p "$(dirname "$CHEZMOI_SOURCE_DIR")"
    ln -s "$HOME/dotfiles" "$CHEZMOI_SOURCE_DIR"
fi

# --- 7. Dotfilesの展開 ---
echo "🔧 Applying dotfiles via Chezmoi..."
mise exec chezmoi -- chezmoi init --apply --force

# --- 8. ツールのインストール ---
echo "⬇️  Installing tools via Mise..."
# config.toml に書かれたツール(Sheldon含む)を一括インストール
mise install --yes

# 上流に新バージョンが出ているツールを表示（メジャー越えも含む。情報目的・終了コードは無視）
echo "🔎 Checking for tool updates (mise outdated --bump)..."
mise outdated --bump || true

# --- 9. AI CLIツールのネイティブインストール ---

# Claude Code （公式インストーラー）
if ! command -v claude >/dev/null 2>&1; then
    echo "🤖 Installing Claude Code..."
    curl -fsSL https://claude.ai/install.sh | bash
fi

# --- 10. Syncing mise changes back to chezmoi ---
echo "🔄 Syncing potential mise config changes back to chezmoi..."
mise exec chezmoi -- chezmoi add ~/.config/mise/config.toml

echo "🎉 Setup Complete! Please restart your shell."