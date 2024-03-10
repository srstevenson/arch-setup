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

info "Configuring pacman..."
sed -i -e "s/^#Color/Color/" -e "s/^#ParallelDownloads/ParallelDownloads/" \
  /etc/pacman.conf

info "Installing ufw..."
pacman -Syu --noconfirm --needed ufw
ufw default deny
ufw limit ssh
ufw --force enable
systemctl enable --now ufw
