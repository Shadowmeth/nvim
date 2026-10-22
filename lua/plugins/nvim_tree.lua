vim.pack.add({ "https://github.com/nvim-tree/nvim-tree.lua" })

-- disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local function on_attach(bufnr)
  local api = require("nvim-tree.api")

  -- Keep all of nvim-tree's default keys
  api.config.mappings.default_on_attach(bufnr)

  vim.keymap.set("n", "q", function()
    -- Count normal (non-floating) windows in this tab
    local wins = vim.tbl_filter(function(win)
      return vim.api.nvim_win_get_config(win).relative == ""
    end, vim.api.nvim_tabpage_list_wins(0))

    if #wins == 1 then
      vim.cmd("quit") -- tree is the last window: quit Neovim
    else
      api.tree.close()
    end
  end, { buffer = bufnr, desc = "Close tree or quit", nowait = true })
end


---@type nvim_tree.config
local config = {
  on_attach = on_attach,
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
