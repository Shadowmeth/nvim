vim.pack.add({ "https://github.com/mfussenegger/nvim-jdtls" })

-- Java debugger with auto hot code replace.
-- Must run before jdtls attaches, or nvim-jdtls sets it up with defaults first.
require("jdtls").setup_dap({ hotcodereplace = "auto" })

local dap = require("dap")

-- Turn off the automatic main class search on <F5>.
-- It fails for projects without a build file and only adds a 2 second wait.
dap.providers.configs["jdtls"] = nil

-- nvim-jdtls fills in the rest when you start it:
-- the class comes from the open file, plus the classpath and java program.
dap.configurations.java = {
  {
    type = "java",
    request = "launch",
    name = "Launch current file",
  },
}

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("user_jdtls_keys", { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client or client.name ~= "jdtls" then
      return
    end

    local jdtls = require("jdtls")
    local buf = args.buf

    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = buf, silent = true, desc = desc })
    end

    local ok, wk = pcall(require, "which-key")
    if ok then
      wk.add({ { "<leader>j", group = "Java", buffer = buf } })
    end

    map("n", "<leader>jo", jdtls.organize_imports, "Organize Imports")
    map("n", "<leader>jv", jdtls.extract_variable, "Extract Variable")
    map("v", "<leader>jv", function() jdtls.extract_variable(true) end, "Extract Variable")
    map("n", "<leader>jc", jdtls.extract_constant, "Extract Constant")
    map("v", "<leader>jm", function() jdtls.extract_method(true) end, "Extract Method")
    map("n", "<leader>jt", jdtls.test_nearest_method, "Test Nearest Method")
    map("n", "<leader>jT", jdtls.test_class, "Test Class")
  end,
})
