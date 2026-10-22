vim.pack.add({ "https://github.com/folke/snacks.nvim" })

---@type snacks.config
local config = {
  picker = { enabled = true },
  notifier = {
    enabled = true,
    timeout = 3000,
  },
}

require("snacks").setup(config)

local map = vim.keymap.set

-- Find files
map("n", "<leader><space>", function() Snacks.picker.smart() end, { desc = "Smart find files" })
map("n", "<leader>ff", function() Snacks.picker.files() end, { desc = "Find files" })
map("n", "<leader>fb", function() Snacks.picker.buffers() end, { desc = "Buffers" })
map("n", "<leader>fr", function() Snacks.picker.recent() end, { desc = "Recent files" })
map("n", "<leader>fc", function()
  Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
end, { desc = "Find config file" })

-- Grep
map("n", "<leader>/", function() Snacks.picker.grep() end, { desc = "Grep" })
map("n", "<leader>sg", function() Snacks.picker.grep() end, { desc = "Grep" })
map("n", "<leader>sB", function() Snacks.picker.grep_buffers() end, { desc = "Grep open buffers" })
map({ "n", "x" }, "<leader>sw", function()
  Snacks.picker.grep_word()
end, { desc = "Grep word or selection" })

-- Search lines in current buffer
map("n", "<leader>sb", function() Snacks.picker.lines() end, { desc = "Buffer lines" })
