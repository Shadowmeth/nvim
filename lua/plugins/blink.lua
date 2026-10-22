vim.pack.add({
  "https://github.com/rafamadriz/friendly-snippets",
  {
    src = "https://github.com/L3MON4D3/LuaSnip",
    version = vim.version.range("2.*"),
  },
  {
    src = "https://github.com/saghen/blink.cmp",
    version = vim.version.range("1.*"),
  },
})


---@module 'blink.cmp'
---@type blink.cmp.Config
local config = {
  -- 'default' (C-y to accept), 'super-tab' (Tab to accept),
  -- 'enter' (Enter to accept), or 'none'
  keymap = { preset = "super-tab" },

  snippets = { preset = "luasnip" },

  appearance = {
    -- 'mono' for "Nerd Font Mono", 'normal' for "Nerd Font"
    nerd_font_variant = "mono",
  },

  -- Only show docs popup when asked for (C-space)
  completion = {
    documentation = {
      auto_show = false,
    },
  },

  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
  },

  -- Rust fuzzy matcher, falls back to Lua with a warning if missing
  fuzzy = {
    implementation = "prefer_rust_with_warning",
  },
}

require("blink.cmp").setup(config)
