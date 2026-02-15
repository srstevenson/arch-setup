#!/usr/bin/env bash

set -euo pipefail

info() {
  echo -e "\033[1;34m::\033[0m \033[1;37m$*\033[0m"
}

pacman_syu() {
  sudo pacman -Syu --noconfirm --needed "$@"
}

systemctl_enable() {
  sudo systemctl enable --now "$@"
}

info "Enabling sshd..."
pacman_syu openssh
systemctl_enable sshd

info "Installing ufw..."
pacman_syu ufw
sudo ufw default deny
sudo ufw limit ssh
sudo ufw --force enable
systemctl_enable ufw
