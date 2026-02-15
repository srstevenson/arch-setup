# arch-setup

This repository provides scripts for installing and setting up Arch Linux
systems.

## Installation

Run `install-arch.sh` from an installation image. This performs an automated
installation with an encrypted ext4 root partition, systemd-boot as the
bootloader, periodic file system TRIM, and swap on zram.

## Setup

After rebooting into the newly installed system, run the `setup-*.sh` scripts
that match the system's role:

- `setup-base.sh` configures pacman and selects local HTTPS mirrors.
- `setup-sshd.sh` enables the OpenSSH daemon and configures ufw to deny inbound
  traffic other than SSH.
- `setup-dev.sh` installs development tools, including editors, version control
  tooling, language servers, formatters, and linters.
