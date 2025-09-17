---@brief
---
--- https://github.com/EmmyLuaLs/emmylua-analyzer-rust
---
--- Emmylua Analyzer Rust. Language Server for Lua.
---
--- `emmylua_ls` can be installed using `cargo` by following the instructions[here]
--- (https://github.com/EmmyLuaLs/emmylua-analyzer-rust?tab=readme-ov-file#install).
---
--- The default `cmd` assumes that the `emmylua_ls` binary can be found in `$PATH`.
--- It might require you to provide cargo binaries installation path in it.

---@type vim.lsp.Config
return {
  cmd = { 'emmylua_ls' },
  filetypes = { 'lua' },
  root_markers = {
    '.luarc.json',
    '.emmyrc.json',
    '.luacheckrc',
    '.git',
  },
  workspace_required = false,
  settings = {
    emmylua = {
      workspace = {
        checkThirdParty = false, -- don’t nag about library code
        library = vim.api.nvim_get_runtime_file("", true),
      },
      diagnostics = {
        enable = true,
        globals = { "vim" }, -- don’t warn about Neovim globals
      },
    },
  }, 
}
