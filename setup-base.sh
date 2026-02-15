#!/usr/bin/env bash

set -euo pipefail

info() {
  echo -e "\033[1;34m::\033[0m \033[1;37m$*\033[0m"
}

pacman_syu() {
  sudo pacman -Syu --noconfirm --needed "$@"
}

info "Configuring pacman..."
sudo sed -Ei -e "s/^#(Color)/\1/" -e "s/^#(ParallelDownloads)/\1/" \
  /etc/pacman.conf

info "Selecting mirrors..."
pacman_syu reflector
sudo reflector --country "United Kingdom" --protocol https --sort rate \
  --save /etc/pacman.d/mirrorlist
