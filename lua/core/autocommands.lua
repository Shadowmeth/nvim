-- Highlight text briefly after yanking
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight selection on yank",
  group = vim.api.nvim_create_augroup("YankHighlight", { clear = true }),
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 150 })
  end,
})
