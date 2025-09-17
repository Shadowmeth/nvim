-- init.lua
-- Leader: set early
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Load core modules
require("core")
require("lsp")

-- Load plugins: gather plugin specs from lua/plugins/*.lua
local plugin_dir = vim.fn.stdpath("config") .. "/lua/plugins"
local plugin_files = vim.fn.globpath(plugin_dir, "*.lua", false, true) -- returns list
local plugins = {}
for _, file in ipairs(plugin_files) do
  local spec = dofile(file)
  if type(spec) == "table" then
    -- if the file returns a list of specs, extend; otherwise insert single
    if vim.islist(spec) then
      vim.list_extend(plugins, spec)
    else
      table.insert(plugins, spec)
    end
  end
end

-- Call lazy.setup with the aggregated specs
require("lazy").setup(plugins, {
  checker = {
    enabled = true, -- auto-reload when plugin files change
  },
})
