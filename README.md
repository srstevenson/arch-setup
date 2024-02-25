# arch-setup

## `install-arch.sh`

`install-arch.sh` performs an automated installation of Arch Linux with an
encrypted ext4 root partition, systemd-boot as the boot loader, periodic file
system TRIM, and swap on zram.

## pre-commit hooks

[pre-commit] is used to run formatters and linters before committing changes.
Install pre-commit and dependencies with `pacman -Syu pre-commit shfmt` and
install the pre-commit hooks with `pre-commit install`.

[pre-commit]: https://pre-commit.com/
