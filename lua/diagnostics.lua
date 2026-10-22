-- diagnostics.lua

-- Nerd Font icons (written as unicode escapes so they never come through empty)
local icons = {
  [vim.diagnostic.severity.ERROR] = "\u{f057}", -- nf-fa-times_circle
  [vim.diagnostic.severity.WARN] = "\u{f071}", -- nf-fa-warning
  [vim.diagnostic.severity.INFO] = "\u{f05a}", -- nf-fa-info_circle
  [vim.diagnostic.severity.HINT] = "\u{f0335}", -- nf-md-lightbulb
}

local signs = {
  text = icons,
}

-- Default: only icons in the sign column, no text or underlines
vim.diagnostic.config({
  virtual_text = false,
  virtual_lines = false,
  signs = signs,
  underline = false,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "rounded",
    source = true,
    header = "",
    prefix = function(diagnostic)
      local icon = icons[diagnostic.severity]
      local hl = ({
        [vim.diagnostic.severity.ERROR] = "DiagnosticError",
        [vim.diagnostic.severity.WARN] = "DiagnosticWarn",
        [vim.diagnostic.severity.INFO] = "DiagnosticInfo",
        [vim.diagnostic.severity.HINT] = "DiagnosticHint",
      })[diagnostic.severity]
      return icon .. " ", hl
    end,
  },
})

local map = vim.keymap.set

-- Show diagnostics for the current line
map("n", "gl", function()
  vim.diagnostic.open_float()
end, { desc = "Line diagnostics" })

-- Jump to next / previous diagnostic and show it
map("n", "]d", function()
  vim.diagnostic.jump({ count = 1 })
  vim.diagnostic.open_float()
end, { desc = "Next diagnostic" })

map("n", "[d", function()
  vim.diagnostic.jump({ count = -1 })
  vim.diagnostic.open_float()
end, { desc = "Previous diagnostic" })

-- Toggle signs in the sign column
local enabled = true

map("n", "<leader>ud", function()
  enabled = not enabled
  vim.diagnostic.config({
    signs = enabled and signs or false,
  })
  vim.notify("Diagnostic signs " .. (enabled and "shown" or "hidden"))
end, { desc = "Toggle diagnostic signs" })

-- All diagnostics of this buffer in the location list
map("n", "<leader>ld", function()
  vim.diagnostic.setloclist()
end, { desc = "List diagnostics" })
