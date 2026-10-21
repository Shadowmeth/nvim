vim.pack.add({ "https://github.com/nvim-tree/nvim-tree.lua" })

-- disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

---@type nvim_tree.config
local config = {
  sort = {
    sorter = "case_sensitive",
  },
  view = {
    width = 30,
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = true,
  },
}

require("nvim-tree").setup(config)

local api = require("nvim-tree.api")

vim.keymap.set("n", "<leader>e", function()
  if vim.bo.filetype == "NvimTree" then
    vim.cmd("wincmd p")
  else
    api.tree.focus()
  end
end, { desc = "File Explorer" })
