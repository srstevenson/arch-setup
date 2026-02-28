# show this help message (default)
default:
    @just -l

# format with shfmt
fmt:
    shfmt -ci -i 2 -w *.sh

# lint with shellcheck
lint:
    shellcheck -s bash *.sh
