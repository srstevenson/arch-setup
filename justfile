# list available recipes
default:
    @just -l

# format with shfmt and lint with shellcheck
check: fmt lint

# format with shfmt
fmt:
    shfmt -ci -i 2 -w *.sh

# lint with shellcheck
lint:
    shellcheck -s bash *.sh
