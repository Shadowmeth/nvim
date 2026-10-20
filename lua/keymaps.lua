-- keymaps.lua

local map = vim.keymap.set

-- Save and quit
map("n", "<leader>w", "<cmd>silent write<CR>", { desc = "Save" })
map("n", "<leader>q", "<cmd>quit<CR>", { desc = "Quit" })
map("n", "<leader>Q", "<cmd>quitall<CR>", { desc = "Quit all" })

-- Resize windows
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Narrower window" })
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Wider window" })
map("n", "<A-Up>", "<cmd>resize +2<CR>", { desc = "Taller window" })
map("n", "<A-Down>", "<cmd>resize -2<CR>", { desc = "Shorter window" })

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

-- Paste over a selection without losing what you copied
map("x", "<leader>p", [["_dP]], { desc = "Paste without yanking" })

-- System clipboard
map({ "n", "v" }, "<leader>y", [["+y]], { desc = "Copy to system clipboard" })
map("n", "<leader>Y", [["+Y]], { desc = "Copy line to system clipboard" })

-- Buffers
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Close buffer" })

-- Terminal: Esc goes back to normal mode
map("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })
