describe("integration tests: ", function()
    it("Telescope repo repo", function()
        vim.cmd.Telescope({ args = { "repo", "repo" } })
    end)

    it("Telescope repo list", function()
        vim.cmd.Telescope({ args = { "repo", "list" } })
    end)

    it("Telescope repo cached_list", function()
        vim.cmd.Telescope({ args = { "repo", "cached_list" } })
    end)
end)
