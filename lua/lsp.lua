-- lsp.lua
--
-- Server settings live in ~/.config/nvim/lsp/<name>.lua (e.g. lsp/clangd.lua).
-- Neovim loads those files on its own; this file just turns them on.

-- Add server names here. Each name must match a file in nvim/lsp/.
local servers = {
  "clangd",
}

vim.lsp.enable(servers)

-- Off by default (toggle with the <leader>u keys below)
local state = {
  inlay_hints = false,
  semantic_tokens = false,
  highlight = false,
}

vim.lsp.inlay_hint.enable(state.inlay_hints)
vim.lsp.semantic_tokens.enable(state.semantic_tokens)

-- Highlight other uses of the word under the cursor (only when turned on)
local hl_group = vim.api.nvim_create_augroup("user_lsp_highlight", { clear = true })

local function setup_highlight(buf, client)
  if not client:supports_method("textDocument/documentHighlight") then
    return
  end

  vim.api.nvim_clear_autocmds({ group = hl_group, buffer = buf })

  vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
    group = hl_group,
    buffer = buf,
    callback = function()
      if state.highlight then
        vim.lsp.buf.document_highlight()
      end
    end,
  })

  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "BufLeave" }, {
    group = hl_group,
    buffer = buf,
    callback = function()
      vim.lsp.buf.clear_references()
    end,
  })
end

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("user_lsp_attach", { clear = true }),
  callback = function(args)
    local buf = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then
      return
    end

    setup_highlight(buf, client)

    local function map(keys, fn, desc, mode)
      vim.keymap.set(mode or "n", keys, fn, { buffer = buf, desc = desc })
    end

    -- Neovim already gives you: K (hover), grn (rename), gra (code action),
    -- grr (references), gri (implementation), grt (type definition),
    -- gO (document symbols), <C-s> in insert mode (signature help).

    require("which-key").add({
      { "<leader>l", group = "LSP" },
    })

    -- Go to
    map("gd", vim.lsp.buf.definition, "Go to definition")
    map("gD", vim.lsp.buf.declaration, "Go to declaration")
    map("gy", vim.lsp.buf.type_definition, "Go to type definition")
    map("gI", vim.lsp.buf.implementation, "Go to implementation")

    -- Formatting (whole file in normal mode, selection in visual mode)
    map("<leader>lf", function()
      vim.lsp.buf.format({ async = true })
    end, "Format", { "n", "x" })

    -- Other LSP actions
    map("<leader>lr", vim.lsp.buf.rename, "Rename symbol")
    map("<leader>la", vim.lsp.buf.code_action, "Code action", { "n", "x" })
    map("<leader>lR", function() Snacks.picker.lsp_references() end, "References")
    map("<leader>ls", function() Snacks.picker.lsp_symbols() end, "Document symbols")
    map("<leader>lS", function() Snacks.picker.lsp_workspace_symbols() end, "Workspace symbols")
    map("<leader>li", vim.lsp.buf.incoming_calls, "Incoming calls")
    map("<leader>lo", vim.lsp.buf.outgoing_calls, "Outgoing calls")
    map("<leader>lh", vim.lsp.buf.signature_help, "Signature help")
  end,
})

require("which-key").add({
  { "<leader>u", group = "Toggles" },
})
-- Toggles
local map = vim.keymap.set

map("n", "<leader>uh", function()
  state.inlay_hints = not state.inlay_hints
  vim.lsp.inlay_hint.enable(state.inlay_hints)
  vim.notify("Inlay hints " .. (state.inlay_hints and "on" or "off"))
end, { desc = "Toggle inlay hints" })

map("n", "<leader>us", function()
  state.semantic_tokens = not state.semantic_tokens
  vim.lsp.semantic_tokens.enable(state.semantic_tokens)
  vim.notify("Semantic highlighting " .. (state.semantic_tokens and "on" or "off"))
end, { desc = "Toggle semantic highlighting" })

map("n", "<leader>ur", function()
  state.highlight = not state.highlight
  if not state.highlight then
    vim.lsp.buf.clear_references()
  end
  vim.notify("Symbol highlighting " .. (state.highlight and "on" or "off"))
end, { desc = "Toggle symbol highlighting" })
