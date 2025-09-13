-- Global keybinds (DO NOT SET PLUGIN KEYBINDS HERE!)

-- Save buffer
vim.keymap.set("n", "<leader>w", function() vim.cmd("w") end, { silent = true, noremap = true})

-- Quit neovim
vim.keymap.set("n", "<leader>q", function() vim.cmd("q") end, { silent = true, noremap = true })

-- Easier window navigation (like Ctrl-h/j/k/l)
vim.keymap.set("n", "<C-h>", "<C-w>h", { silent = true, noremap = true })
vim.keymap.set("n", "<C-j>", "<C-w>j", { silent = true, noremap = true })
vim.keymap.set("n", "<C-k>", "<C-w>k", { silent = true, noremap = true })
vim.keymap.set("n", "<C-l>", "<C-w>l", { silent = true, noremap = true })
