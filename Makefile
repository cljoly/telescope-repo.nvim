test:
	@nvim --headless -c "PlenaryBustedDirectory lua/tests/"

fmt:
	@stylua lua
