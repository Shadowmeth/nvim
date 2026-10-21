vim.pack.add({ "https://github.com/folke/which-key.nvim" })

local wk = require("which-key")

---@class wk.opts
local defaults = {
  preset = "helix",
  icons = {
    breadcrumb = "",
    group = "",
    ellipsis = "",
    mappings = false,
  },
}

wk.setup(defaults)
