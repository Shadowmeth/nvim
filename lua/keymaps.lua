--- keymaps.lua

local map = vim.keymap.set

-- Resize windows
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Narrower window" })
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Wider window" })
map("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Taller window" })
map("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Shorter window" })

-- Splits
map("n", "<leader>\\", "<cmd>vsplit<CR>", { desc = "Vertical split" })
map("n", "<leader>-", "<cmd>split<CR>", { desc = "Horizontal split" })

-- Keep selection after indenting
map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })

-- Move selected lines up/down
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move lines down", silent = true })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move lines up", silent = true })

-- Keep cursor in the middle when jumping
map("n", "<C-d>", "<C-d>zz", { desc = "Half page down" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half page up" })
map("n", "n", "nzzzv", { desc = "Next match" })
map("n", "N", "Nzzzv", { desc = "Previous match" })

-- Buffers
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Close buffer" })

-- Terminal: Esc goes back to normal mode
map("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })
