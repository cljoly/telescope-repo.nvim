describe("integration tests: ", function()
    it("Telescope repo repo", function()
        vim.cmd([[Telescope repo repo]])
    end)

    it("Telescope repo list", function()
        vim.cmd([[Telescope repo list]])
    end)

    it("Telescope repo cached_list", function()
        vim.cmd([[Telescope repo cached_list]])
    end)
end)
