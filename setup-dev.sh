#!/usr/bin/env bash

set -euo pipefail

info() {
  printf "\033[1;34m::\033[0m \033[1;37m%s\033[0m\n" "$*"
}

pacman_syu() {
  sudo pacman -Syu --noconfirm --needed "$@"
}

info "Installing development tools..."
pacman_syu chezmoi difftastic fd fzy git helix jujutsu just neovim ripgrep \
  starship tmux typos-lsp
sudo ln -fs /usr/bin/helix /usr/local/bin/hx

info "Installing TOML tools..."
pacman_syu taplo-cli

info "Installing YAML tools..."
pacman_syu prettier

info "Installing shell tools..."
pacman_syu bash-language-server shellcheck shfmt

info "Installing Lua tools..."
pacman_syu lua-language-server stylua

info "Installing Python tools..."
pacman_syu ruff ty

info "Installing Rust tools..."
pacman_syu rustup
rustup default stable
rustup component add rust-analyzer
