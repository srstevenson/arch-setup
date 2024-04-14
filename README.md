# arch-setup

This repository provides scripts for installing and setting up Arch Linux
systems.

## Scripts

The following scripts are provided and should be run in the order listed.

- `install-arch.sh` performs an automated installation of Arch Linux with an
  encrypted ext4 root partition, systemd-boot as the bootloader, periodic file
  system TRIM, and swap on zram.
- `setup-arch.sh` configures an installed system, such as one installed with
  `install-arch.sh`, for development use. It configures pacman and installs ufw
  to manage the netfilter firewall, and installs development tools including
  editors, compilers, formatters, and linters.

## pre-commit hooks

[pre-commit] is used to run formatters and linters before committing changes.
Install pre-commit and dependencies with `pacman -Syu pre-commit shfmt` and add
the pre-commit hooks to your local repository with `pre-commit install`.

[pre-commit]: https://pre-commit.com/
