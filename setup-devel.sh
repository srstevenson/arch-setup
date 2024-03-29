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
  exit 77 # EX_NOPERM
fi

info "Installing development tools..."
pacman -Syu --noconfirm --needed bat difftastic fd git git-absorb helix \
  pre-commit neovim ripgrep starship tmux zellij
ln -fs /usr/bin/helix /usr/local/bin/hx

info "Installing Markdown tools..."
pacman -Syu --noconfirm --needed mdformat

info "Installing TOML tools..."
pacman -Syu --noconfirm --needed taplo-cli

info "Installing YAML tools..."
pacman -Syu --noconfirm --needed prettier

info "Installing shell development tools..."
pacman -Syu --noconfirm --needed bash-language-server shellcheck shfmt

info "Installing Lua development tools..."
pacman -Syu --noconfirm --needed lua-language-server stylua

info "Installing Python development tools..."
pacman -Syu --noconfirm --needed pyright ruff ruff-lsp

info "Installing Rust development tools..."
if [[ ! -d /home/scott/.rustup ]]; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o /tmp/rustup.sh
  sudo -u scott bash /tmp/rustup.sh -q -y --no-modify-path
  rm /tmp/rustup.sh
fi
if [[ ! -f /home/scott/.cargo/bin/rust-analyzer ]]; then
  sudo -u scott /home/scott/.cargo/bin/rustup component add rust-analyzer
fi
sudo -u scott /home/scott/.cargo/bin/rustup update
