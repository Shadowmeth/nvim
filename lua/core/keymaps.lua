-- Global keybinds (DO NOT SET PLUGIN KEYBINDS HERE!)

-- Save buffer
vim.keymap.set("n", "<leader>w", function() vim.cmd("w") end, { desc = "Write", silent = true, noremap = true})

-- Quit neovim
vim.keymap.set("n", "<leader>q", function() vim.cmd("q") end, { desc = "Quit", silent = true, noremap = true })
