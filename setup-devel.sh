#!/usr/bin/env bash

set -euo pipefail

info() {
  echo -e "\033[1;34m::\033[0m \033[1;37m$*\033[0m"
}

error() {
  echo -e "\033[1;31m==> ERROR:\033[0m \033[1;37m$*\033[0m" >&2
}

if [[ "$EUID" -ne 0 ]]; then
  error "script must be run as root"
  exit 1 # EPERM
fi

info "Installing man pages..."
pacman -Syu --noconfirm --needed man-db man-pages

info "Installing development tools..."
pacman -Syu --noconfirm --needed bat fd git helix pre-commit neovim ripgrep \
  taplo-cli tmux zellij
ln -fs /usr/bin/helix /usr/local/bin/hx

info "Installing shell development tools..."
pacman -Syu --noconfirm --needed bash-language-server shellcheck shfmt

info "Installing Lua development tools..."
pacman -Syu --noconfirm --needed lua-language-server stylua

info "Installing Python development tools..."
pacman -Syu --noconfirm --needed pyright ruff ruff-lsp
