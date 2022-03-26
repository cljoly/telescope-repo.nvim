.PHONY: test, fmt, lint

all: test lint

test:
	@nvim --headless -c "PlenaryBustedDirectory lua/tests/"

fmt:
	@stylua lua

lint: fmt
	@luacheck lua/telescope
