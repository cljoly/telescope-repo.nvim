.PHONY: test fmt lint test_ci

all: test lint

test: test_ci

test_ci:
	@nvim --clean --headless -c "PlenaryBustedDirectory lua/tests/ {}" -c "qa!"

fmt:
	@stylua lua

lint:
	@luacheck lua/telescope

tags:
	@ctags -R . ~/.local/share/nvim/site/pack/*/*/*/lua/
