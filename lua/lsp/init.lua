vim.lsp.enable({ "clangd", "emmylua_ls" })

vim.diagnostic.config({
    virtual_text = { current_line = true },
    underline = false,
    update_in_insert = false,
    signs = false,
})
