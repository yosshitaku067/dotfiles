# My Dotfiles

## Overview

This is my personal dotfiles repository for building my development environment.
Based on Zsh, it aims to automate the management of various tool versions and plugins to reproduce a consistent and modern CLI environment anywhere.

It uses [Chezmoi](https://www.chezmoi.io/) for management and is intended to be cloned into `~/dotfiles` for deployment.

## Key Features

- **Shell**: Uses Zsh as the default shell.
- **Prompt**: A modern and informative prompt by [Starship](https://starship.rs/).
- **Tool Management**: Version management of CLI tools with [Mise](https://mise.jdx.dev/).
- **Plugin Management**: Management of Zsh plugins with [Sheldon](https://sheldon.cli.rs/).
- **Fuzzy Search**: Powerful completion features with [fzf](https://github.com/junegunn/fzf) and [fzf-tab](https://github.com/Aloxaf/fzf-tab).
- **Enhanced DX**: Basic development experience improvements like syntax highlighting and auto-suggestions.

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
- Development language runtimes like `node`, `python`, `rust`, and `golang`.

## Zsh Plugins Managed by `sheldon`

These are the main plugins listed in `plugins.toml`.

- `zsh-defer`: Speeds up shell startup by deferring plugin loading.
- `zsh-autosuggestions`: Suggests commands as you type based on history.
- `zsh-completions`: Additional completion definitions for many commands.
- `fzf-tab`: Interactive tab completion with `fzf`.
- `zsh-abbr`: Defines abbreviations for frequently used commands.
- `zsh-history-substring-search`: Allows searching history with partial matches.
- `zsh-syntax-highlighting`: Provides syntax highlighting for the command line.

## Installation

These dotfiles are intended for Debian-based Linux distributions.

1.  **Clone the repository**
    ```bash
    git clone https://github.com/<YOUR_USERNAME>/dotfiles.git ~/dotfiles
    ```

2.  **Run the installation script**
    Execute the `install.sh` script in the repository. This will automatically install necessary packages, set up `mise` and `chezmoi`, apply the dotfiles, and install the tools.

    ```bash
    cd ~/dotfiles
    ./install.sh
    ```

3.  **Restart your shell**
    After the installation is complete, please restart your shell (or log in again).

## Directory Structure

- `dot_*`: Files that will be placed directly in the home directory by `chezmoi` (e.g., `dot_zshrc` -> `.zshrc`).
- `dot_config/`: Configuration files that will be placed under `~/.config` by `chezmoi`.
  - `mise/config.toml`: List of tools managed by `mise`.
  - `sheldon/plugins.toml`: List of plugins managed by `sheldon`.
  - `starship.toml`: Prompt configuration for `starship`.
- `install.sh`: The setup script.