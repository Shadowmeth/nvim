vim.pack.add({ "https://github.com/mason-org/mason.nvim" })

require("mason").setup({
  PATH = "prepend",
  ui = {
    icons = {
      package_install = "✓",
      package_pending = "➜",
      package_uninstalled = "✗",
    },
  },
})
