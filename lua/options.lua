-- options.lua

-- Leader keys (set before any keymaps or plugins load)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt

-- Indentation: 2 spaces by default (some filetypes use 4, see autocmds.lua)
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftround = true
opt.smartindent = true
opt.breakindent = true

-- Line numbers and side columns
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.cursorline = true

-- No status line, no command line unless typing a command
opt.laststatus = 0
opt.cmdheight = 0
opt.ruler = false
opt.showmode = false
opt.showcmd = false

-- Searching
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true
opt.inccommand = "split"

-- Splits
opt.splitright = true
opt.splitbelow = true

-- Scrolling and wrapping
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = false

-- Show hidden characters
opt.list = true
opt.listchars = {
  tab = "» ",
  trail = "·",
  nbsp = "␣",
}

-- Files
opt.undofile = true
opt.swapfile = false
opt.backup = false
opt.confirm = true

-- Timing
opt.updatetime = 250
opt.timeoutlen = 300

-- Look and feel
opt.termguicolors = true
opt.mouse = "a"
opt.pumheight = 10
opt.completeopt = { "menu", "menuone", "noselect" }
opt.fillchars = {
  eob = " ",
}

-- Code Folding
opt.foldlevelstart = 99

local write_cmds = { "w", "wa", "wq", "wqa", "x", "xa", "up", "update" }

for _, cmd in ipairs(write_cmds) do
  vim.keymap.set("ca", cmd, function()
    if vim.fn.getcmdtype() == ":" and vim.fn.getcmdline() == cmd then
      return "silent " .. cmd
    end
    return cmd
  end, { expr = true })
end

-- System clipboard: left off on purpose (see the dock flashing issue).
-- Use "+y and "+p when you want it, or uncomment the line below.
opt.clipboard = "unnamedplus"

-- To use system clipboard:
-- sudo apt install wl-clipboard
local osc52 = require("vim.ui.clipboard.osc52")

vim.g.clipboard = {
  name = "osc52",
  copy = {
    ["+"] = osc52.copy("+"),
    ["*"] = osc52.copy("*"),
  },
  paste = {
    ["+"] = { "wl-paste", "--no-newline" },
    ["*"] = { "wl-paste", "--no-newline", "--primary" },
  },
}
