vim.pack.add({ "https://github.com/nvim-treesitter/nvim-treesitter" })
vim.pack.add({{ src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects", version = "main" }})

local ts_langs = {
  -- Systems / embedded
  "c",
  "cpp",
  "rust",
  "zig",
  "asm",
  "nasm",
  "objdump",
  "disassembly",
  "llvm",
  "linkerscript",
  "devicetree",
  "kconfig",
  "bitbake",
  "udev",

  -- Build tools
  "cmake",
  "make",
  "meson",
  "ninja",

  -- Scripting
  "python",
  "lua",
  "luadoc",
  "bash",
  "vim",
  "vimdoc",
  "query",

  -- Other languages
  "go",
  "gomod",
  "java",
  "javascript",
  "jsdoc",
  "typescript",
  "tsx",
  "html",
  "css",
  "sql",

  -- Data / config
  "json",
  "yaml",
  "toml",
  "ini",
  "xml",
  "csv",
  "dockerfile",
  "ssh_config",
  "requirements",

  -- Docs / git
  "markdown",
  "markdown_inline",
  "comment",
  "regex",
  "printf",
  "diff",
  "gitcommit",
  "git_config",
  "git_rebase",
  "gitattributes",
  "gitignore",
}

require("nvim-treesitter").setup({
  -- Directory to install parsers and queries to (prepended to `runtimepath` to have priority)
  install_dir = vim.fn.stdpath("data") .. "/site"
})

require("nvim-treesitter").install(ts_langs)

vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    -- Start treesitter only if a parser exists for this filetype
    if not pcall(vim.treesitter.start, args.buf) then
      return
    end
    vim.treesitter.start()
    vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
    vim.wo[0][0].foldmethod = "expr"
  end,
})

require("nvim-treesitter-textobjects").setup({
  select = {
    lookahead = true, -- jump forward to the next match if cursor isn't on one
  },
  move = {
    set_jumps = true, -- add moves to the jumplist (<C-o> to go back)
  },
})

local select = require("nvim-treesitter-textobjects.select")
local move = require("nvim-treesitter-textobjects.move")
local swap = require("nvim-treesitter-textobjects.swap")

-- Text objects: key = { query, description }
local objects = {
  k = { "block", "block" },
  c = { "class", "class" },
  ["?"] = { "conditional", "conditional" },
  f = { "function", "function" },
  l = { "loop", "loop" },
  a = { "parameter", "argument" },
}

-- Select: af / if, ac / ic, aa / ia, etc.
for key, obj in pairs(objects) do
  local query, desc = obj[1], obj[2]

  vim.keymap.set({ "x", "o" }, "a" .. key, function()
    select.select_textobject("@" .. query .. ".outer", "textobjects")
  end, { desc = "around " .. desc })

  vim.keymap.set({ "x", "o" }, "i" .. key, function()
    select.select_textobject("@" .. query .. ".inner", "textobjects")
  end, { desc = "inside " .. desc })
end

-- Move and swap: only for block, function, argument (like AstroNvim)
local movable = {
  k = { "@block.outer", "block" },
  f = { "@function.outer", "function" },
  a = { "@parameter.inner", "argument" },
}

for key, obj in pairs(movable) do
  local query, desc = obj[1], obj[2]
  local upper = key:upper()

  -- ]f next start, ]F next end, [f previous start, [F previous end
  vim.keymap.set({ "n", "x", "o" }, "]" .. key, function()
    move.goto_next_start(query, "textobjects")
  end, { desc = "Next " .. desc .. " start" })

  vim.keymap.set({ "n", "x", "o" }, "]" .. upper, function()
    move.goto_next_end(query, "textobjects")
  end, { desc = "Next " .. desc .. " end" })

  vim.keymap.set({ "n", "x", "o" }, "[" .. key, function()
    move.goto_previous_start(query, "textobjects")
  end, { desc = "Previous " .. desc .. " start" })

  vim.keymap.set({ "n", "x", "o" }, "[" .. upper, function()
    move.goto_previous_end(query, "textobjects")
  end, { desc = "Previous " .. desc .. " end" })

  -- >F swap with next, <F swap with previous
  vim.keymap.set("n", ">" .. upper, function()
    swap.swap_next(query)
  end, { desc = "Swap next " .. desc })

  vim.keymap.set("n", "<" .. upper, function()
    swap.swap_previous(query)
  end, { desc = "Swap previous " .. desc })
end
