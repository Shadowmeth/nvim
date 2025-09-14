return {
    "folke/flash.nvim",
    event = "VeryLazy",
    config = function()
        require("flash").setup()
        local flash = require("flash")
        vim.keymap.set({ "n", "x", "o" }, "s", function() flash.jump() end, { silent = true, noremap = true } )
    end,
}
