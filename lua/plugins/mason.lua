vim.pack.add({ "https://github.com/mason-org/mason.nvim" })

require("mason").setup({
  ui = {
    icons = {
      package_install = "✓",
      package_pending = "➜",
      package_uninstalled = "✗",
    },
  },
})
