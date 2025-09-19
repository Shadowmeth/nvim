vim.lsp.enable("clangd")
vim.lsp.enable("emmylua_ls")

vim.diagnostic.config({
    virtual_text = { current_line = false },
    underline = false,
    update_in_insert = false,
    signs = false,
})
