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

pacman_syu() {
  pacman -Syu --noconfirm --needed "$@"
}

info "Configuring pacman..."
sed -Ei -e "s/^#(Color)/\1/" -e "s/^#(ParallelDownloads)/\1/" /etc/pacman.conf

info "Selecting mirrors..."
pacman_syu reflector
reflector --country "United Kingdom" --protocol https --sort rate \
  --save /etc/pacman.d/mirrorlist

info "Installing ufw..."
pacman_syu ufw
ufw default deny
ufw limit ssh
ufw --force enable
systemctl enable --now ufw

info "Installing man pages..."
pacman_syu man-db man-pages

info "Setting login shell..."
pacman_syu fish
chsh -s /usr/bin/fish scott

info "Installing development tools..."
pacman_syu age difftastic fd fzy git helix jujutsu neovim ripgrep starship tmux
ln -fs /usr/bin/helix /usr/local/bin/hx

info "Installing TOML tools..."
pacman_syu taplo-cli

info "Installing YAML tools..."
pacman_syu prettier

info "Installing shell development tools..."
pacman_syu bash-language-server shellcheck shfmt

info "Installing Python development tools..."
pacman_syu pyright ruff

info "Installing Rust development tools..."
pacman_syu rustup
if [[ ! -d /home/scott/.rustup ]]; then
  sudo -u scott rustup default stable
  sudo -u scott rustup component add rust-analyzer
fi
sudo -u scott rustup update
