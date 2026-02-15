#!/usr/bin/env bash

set -euo pipefail

info() {
  echo -e "\033[1;34m::\033[0m \033[1;37m$*\033[0m"
}

pacman_syu() {
  sudo pacman -Syu --noconfirm --needed "$@"
}

info "Installing development tools..."
pacman_syu difftastic fd fzy git helix jujutsu neovim ripgrep starship tmux
sudo ln -fs /usr/bin/helix /usr/local/bin/hx

info "Installing TOML tools..."
pacman_syu taplo-cli

info "Installing YAML tools..."
pacman_syu prettier

info "Installing shell tools..."
pacman_syu bash-language-server shellcheck shfmt

info "Installing Python tools..."
pacman_syu ruff ty

info "Installing Rust tools..."
pacman_syu rustup
rustup default stable
rustup component add rust-analyzer
