.PHONY: test, fmt, lint

all: test lint

test:
	@nvim --headless -c "PlenaryBustedDirectory lua/tests/  { minimal_init = './scripts/minimal_init.vim' }"

fmt:
	@stylua lua

lint:
	@luacheck lua/telescope
