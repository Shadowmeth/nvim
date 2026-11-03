require("vim._core.ui2").enable({
  msg = {
    targets = "msg",
    msg = {
      timeout = 4000, -- how long a message stays up (ms)
    },
  },
})

require("options")
require("keymaps")
require("autocmds")
require("pack")
require("diagnostics")
require("lsp")
