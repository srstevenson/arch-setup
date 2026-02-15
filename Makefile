.DEFAULT_GOAL := help

.PHONY: all
all: fmt lint

.PHONY: fmt
fmt:
	shfmt --case-indent --indent=2 -w *.sh

.PHONY: lint
lint:
	shellcheck *.sh

.PHONY: help
help:
	@echo "Available commands:"
	@echo "  make help     - Show this help message (default)"
	@echo "  make all      - Format (shfmt) and lint (shellcheck)"
	@echo "  make fmt      - Format with shfmt"
	@echo "  make lint     - Lint with shellcheck"
