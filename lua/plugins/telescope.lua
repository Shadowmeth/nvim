return {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        require("telescope").setup({
            extensions = {
                fzf = {
                    fuzzy = true,
                    override_generic_sorter = true,
                    override_file_sort = true,
                    case_mode = "smart_case",
                },
            },
        })

        require("telescope").load_extension("fzf")

        local builtin = require("telescope.builtin")
        local wk = require("which-key")

        wk.add({
            { "<leader>t", group = "+Telescope" },
            { "<leader>tb", function() builtin.buffers() end, silent = true, desc = "Buffers"},
            { "<leader>tf", function() builtin.find_files() end, silent = true, desc = "Files"},
            { "<leader>tg", function() builtin.live_grep() end, silent = true, desc = "Live grep"},
            { "<leader>tz", function() builtin.current_buffer_fuzzy_find() end, silent = true, desc = "Fuzzy current file"},
        })
    end,
}
