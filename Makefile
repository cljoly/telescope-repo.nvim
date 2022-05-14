.PHONY: test, fmt, lint

all: test lint

test_ci:
	@nvim --headless -c "PlenaryBustedDirectory lua/tests/ {}"

fmt:
	@stylua lua

lint:
	@luacheck lua/telescope
