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

info "Configuring pacman..."
sed -i -e "s/^#Color/Color/" -e "s/^#ParallelDownloads/ParallelDownloads/" \
  /etc/pacman.conf

info "Installing ufw..."
pacman -Syu --noconfirm --needed ufw
ufw default deny
ufw limit ssh
ufw --force enable
systemctl enable --now ufw

info "Installing man pages..."
pacman -Syu --noconfirm --needed man-db man-pages

info "Setting login shell..."
pacman -Syu --noconfirm --needed fish
chsh -s /usr/bin/fish scott

info "Installing development tools..."
pacman -Syu --noconfirm --needed age fd fzy git git-absorb git-delta \
  helix pre-commit ripgrep starship tmux
ln -fs /usr/bin/helix /usr/local/bin/hx

info "Installing jump..."
if [[ ! -f /home/scott/.local/bin/jump ]]; then
  sudo -u scott mkdir -p /home/scott/.local/bin
  sudo -u scott curl -Lo /home/scott/.local/bin/jump \
    https://github.com/gsamokovarov/jump/releases/download/v0.51.0/jump_linux_amd64_binary
  sudo -u scott chmod +x /home/scott/.local/bin/jump
fi

info "Installing TOML tools..."
pacman -Syu --noconfirm --needed taplo-cli

info "Installing YAML tools..."
pacman -Syu --noconfirm --needed prettier

info "Installing shell development tools..."
pacman -Syu --noconfirm --needed bash-language-server shellcheck shfmt

info "Installing Python development tools..."
pacman -Syu --noconfirm --needed pyright ruff ruff-lsp

info "Installing Rust development tools..."
pacman -Syu --noconfirm --needed rustup
if [[ ! -d /home/scott/.rustup ]]; then
  sudo -u scott rustup default stable
  sudo -u scott rustup component add rust-analyzer
fi
sudo -u scott rustup update
