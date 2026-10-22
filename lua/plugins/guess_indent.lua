vim.pack.add({ "https://github.com/nmac427/guess-indent.nvim" })

require("guess-indent").setup({
  auto_cmd = true,
  override_editorconfig = false,
})
