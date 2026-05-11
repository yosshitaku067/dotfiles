# My Dotfiles

**English** | [日本語](docs/README.ja.md)

## Overview

This is my personal dotfiles repository for building my development environment.
Based on Zsh, it aims to automate the management of various tool versions and plugins to reproduce a consistent and modern CLI environment anywhere.

It uses [Chezmoi](https://www.chezmoi.io/) for management and is intended to be cloned into `~/dotfiles` for deployment.

Designed to run on any Debian-based environment — native Linux, WSL2, or a Debian-based [Dev Container](https://containers.dev/).

## Key Features

- **Shell**: Uses Zsh as the default shell.
- **Prompt**: A modern and informative prompt by [Starship](https://starship.rs/).
- **Tool Management**: Version management of CLI tools with [Mise](https://mise.jdx.dev/).
- **Plugin Management**: Management of Zsh plugins with [Sheldon](https://sheldon.cli.rs/).
- **Fuzzy Search**: Powerful completion features with [fzf](https://github.com/junegunn/fzf) and [fzf-tab](https://github.com/Aloxaf/fzf-tab).
- **Enhanced DX**: Aliases, abbreviations, syntax highlighting, auto-suggestions, and history substring search bound to arrow keys.
- **Claude Code Integration**: Custom status line, settings merge logic, and personal coding standards for [Claude Code](https://claude.com/claude-code).
- **Portable across Debian environments**: Works on native Debian/Ubuntu, WSL2 (with automatic Windows-browser shims), and Debian-based Dev Containers.

## Tools Managed by `mise`

These are the main tools listed in `config.toml`. They are installed in bulk with the `mise install` command.

- `bat`: A `cat` clone.
- `eza`: A modern replacement for `ls`.
- `fzf`: A command-line fuzzy finder.
- `gh`: GitHub CLI.
- `starship`: The cross-shell prompt.
- `zoxide`: A smarter `cd` command.
- `chezmoi`: Dotfiles manager.
- `delta`: A viewer for `git diff`.
- `ripgrep`, `fd`, `jq`, `dust`, `zellij`, `sheldon`, `cargo-binstall`, `usage`: General CLI utilities.
- Development language runtimes like `node`, `python`, `rust`, and `golang`.

### Updating tool versions

Tool versions in `dot_config/mise/config.toml` are pinned for reproducibility.

- Check for newer versions: `mise outdated`
- Bump pinned versions in place: `mise outdated --bump`
- To upgrade manually: edit the version in `dot_config/mise/config.toml`, then `mise install`

## Zsh Plugins Managed by `sheldon`

These are the main plugins listed in `plugins.toml`.

- `zsh-defer`: Speeds up shell startup by deferring plugin loading.
- `zsh-autosuggestions`: Suggests commands as you type based on history.
- `zsh-completions`: Additional completion definitions for many commands.
- `fzf-tab`: Interactive tab completion with `fzf`.
- `zsh-abbr`: Defines abbreviations for frequently used commands.
- `zsh-history-substring-search`: Allows searching history with partial matches.
- `zsh-syntax-highlighting`: Provides syntax highlighting for the command line.

### Updating plugin versions

Each plugin in `dot_config/sheldon/plugins.toml` is pinned by commit SHA via `rev = "..."` for reproducibility. The trailing comment records the nearest upstream tag as a baseline.

1. Resolve the target commit SHA:
   - For a release tag: `git ls-remote https://github.com/<owner>/<repo> refs/tags/<tag>`
   - For the default-branch HEAD: `git ls-remote https://github.com/<owner>/<repo> HEAD`
   - Or via GitHub CLI: `gh api repos/<owner>/<repo>/commits/<tag-or-branch> --jq .sha`
2. Update the `rev = "..."` value and the nearest-tag comment in `plugins.toml`.
3. Run `chezmoi apply` to propagate the edit to `~/.config/sheldon/plugins.toml`.
4. Run `sheldon lock --update` to refetch the plugin at the new revision and refresh `~/.local/share/sheldon/plugins.lock`.

## Shell Aliases, Functions & Keybindings

Defined in `dot_zshenv` and `dot_zshrc`.

### Aliases
- `cat` → `bat` (falls back to `cat` if `bat` is missing).
- `ls` → `eza --icons --git`; `ll` → `eza -l --icons --git`.
- `g` → `git`.
- `dot` → `code ~/dotfiles` (open the dotfiles repo in VS Code).

### Functions
- `lcurl`: Restricts `curl` to `localhost` only — prevents accidental requests to unintended hosts.
- `dcurl`: Restricts `curl` to `host.docker.internal` — convenience wrapper for hitting services running on the Docker host from inside a container.

### Keybindings & Completion
- Up/Down arrow keys are bound to `zsh-history-substring-search` (partial-match history navigation).
- fzf-tab previews are configured for `cd` (directory listing via `eza`) and `git checkout/switch/branch` (graph log with branch preview).

## Claude Code Integration

This repo ships an opinionated [Claude Code](https://claude.com/claude-code) setup. The Claude Code native installer is also invoked from `install.sh`.

- **`private_dot_claude/CLAUDE.md`**: Personal global instructions (response language, naming conventions, TypeScript rules, branch management policy).
- **`private_dot_claude/executable_status-line.js`**: Custom status line that displays model name, current directory, git branch, cumulative token usage with compaction-threshold coloring, and session cost in USD.
- **`.chezmoitemplates/claude-settings-base.json`**: Base settings template covering `statusLine`, `plugins`, `permissions` (allow/deny/ask), `attribution`, and environment variables.
- **`private_dot_claude/modify_settings.json.tmpl`**: A chezmoi `modify_` template that merges the base settings into an existing `~/.claude/settings.json` via `jq`. The dotfiles side wins for known keys (e.g. `statusLine`, `env`), while `permissions.allow / deny / ask` are unioned so rules added via the UI are preserved.

## Supported Environments

The setup is environment-agnostic as long as the host is Debian-based. The same `install.sh` is intended for use in any of:

### Native Debian / Ubuntu
Runs as-is — no special handling.

### WSL2
When `install.sh` detects WSL2 (via `/proc/version`):

- Generates `~/.local/bin/xdg-open` as a wrapper that delegates to the Windows default browser via `rundll32 url.dll,FileProtocolHandler`.
- `dot_zshenv` sets `$BROWSER` to the same handler so CLI tools that read `$BROWSER` directly also work.

### Debian-based Dev Container
Intended to be invoked as a postCreate / postStart step (e.g. from `devcontainer.json`'s `postCreateCommand`). Because the host is already a containerized Debian, no WSL2 shims are generated. The `dcurl` helper (which restricts `curl` to `host.docker.internal`) is also useful here for hitting services running on the Docker host from inside the container.

## Installation

These dotfiles are intended for Debian-based Linux distributions.

### Prerequisites
- Debian / Ubuntu (or another `apt-get`-based distro). `install.sh` exits immediately if `apt-get` is unavailable. This includes native Linux, WSL2, and Debian-based Dev Containers.
- Optional: WSL2 — additional browser-handling shims are installed automatically when detected.
- The script is idempotent: every tool install is guarded by a `command -v` check, so re-running is safe (handy for Dev Container rebuilds).

### Steps

1.  **Clone the repository**
    ```bash
    git clone https://github.com/<YOUR_USERNAME>/dotfiles.git ~/dotfiles
    ```

2.  **Run the installation script**
    Execute the `install.sh` script in the repository. This will install necessary apt packages, set up `mise` and `chezmoi`, apply the dotfiles, install all `mise`-managed tools, and run the Claude Code native installer.

    ```bash
    cd ~/dotfiles
    ./install.sh
    ```

3.  **Restart your shell**
    After the installation is complete, please restart your shell (or log in again).

## Directory Structure

This repo follows [chezmoi naming conventions](https://www.chezmoi.io/reference/source-state-attributes/) — file/directory prefixes determine how chezmoi materializes them in the home directory.

- `dot_*`: Becomes a dotfile in the home directory (e.g. `dot_zshrc` → `~/.zshrc`).
- `dot_config/`: Materialized under `~/.config/`.
  - `mise/config.toml`: Tools managed by `mise`.
  - `sheldon/plugins.toml`: Plugins managed by `sheldon`.
  - `starship.toml`: Prompt configuration.
  - `git/ignore`: Global gitignore (e.g. excludes `**/.claude/settings.local.json`).
- `private_*`: Deployed with `0600` permissions.
  - `private_dot_claude/`: Claude Code configuration (`CLAUDE.md`, `status-line.js`, settings merge template).
- `executable_*`: Deployed with the executable bit set (e.g. `executable_status-line.js`).
- `*.tmpl`: chezmoi template — rendered at apply time. `modify_*.tmpl` is a special form that transforms an existing target file rather than overwriting it (used for merging Claude Code settings).
- `.chezmoitemplates/`: Reusable template fragments referenced from `*.tmpl` files.
- `.chezmoiignore`: Files in this repo that should NOT be deployed to the home directory (e.g. `install.sh`, `README.md`).
- `install.sh`: The setup script.
