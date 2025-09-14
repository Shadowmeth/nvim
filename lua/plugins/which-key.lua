return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
        require("which-key").setup({
            preset = "modern",
            notify = true,
            delay = 200,
            filter = function(mapping)
                -- don't include mappings without a description
                return mapping.desc and mapping.desc ~= ""
            end,
            icons = {
                mappings = false,
            },
        })
    end,
}
