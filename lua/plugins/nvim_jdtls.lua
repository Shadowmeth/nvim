vim.pack.add({ "https://github.com/mfussenegger/nvim-jdtls" })

vim.api.nvim_create_autocmd("FileType", {
  pattern = "java",
  callback = function(args)
    local jdtls = require("jdtls")
    local dap_ok, dap = pcall(require, "dap")

    -- 1. Ensure nvim-dap configurations table for java exists
    if dap_ok then
      dap.configurations.java = dap.configurations.java or {}
    end

    -- 2. Define the Mason jdtls binary path (falls back to "jdtls" in $PATH)
    local mason_bin = vim.fn.stdpath("data") .. "/mason/bin/jdtls"
    local jdtls_bin = vim.fn.executable(mason_bin) == 1 and mason_bin or "jdtls"

    -- 3. Find the project root
    local root_markers = { "gradlew", "mvnw", "pom.xml", "build.gradle", ".git" }
    local root_dir = vim.fs.root(args.buf, root_markers) or vim.fn.getcwd()

    -- 4. Create a unique workspace directory per project
    local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
    local workspace_dir = vim.fn.stdpath("cache") .. "/jdtls/workspace/" .. project_name

    -- 5. Locate Mason installation paths for Java debug & test plugins
    local mason_path = vim.fn.stdpath("data") .. "/mason/packages/"
    local bundles = {}

    local debug_adapter_path = mason_path .. "java-debug-adapter/extension/server/"
    local jar_patterns = {
      debug_adapter_path .. "com.microsoft.java.debug.plugin-*.jar",
    }

    local test_path = mason_path .. "java-test/extension/server/"
    table.insert(jar_patterns, test_path .. "*.jar")

    for _, pattern in ipairs(jar_patterns) do
      for _, bundle in ipairs(vim.split(vim.fn.glob(pattern, true), "\n")) do
        if bundle ~= "" then
          table.insert(bundles, bundle)
        end
      end
    end

    -- 6. Build the JDTLS configuration table
    local config = {
      name = "jdtls",
      cmd = {
        jdtls_bin,
        "--java-executable",
        "/usr/lib/jvm/java-25-openjdk-amd64/bin/java",
        "-data",
        workspace_dir,
      },
      root_dir = root_dir,
      init_options = {
        bundles = bundles,
      },
      settings = {
        java = {
          configuration = {
            runtimes = {
              {
                name = "JavaSE-21",
                path = "/usr/lib/jvm/java-21-openjdk-amd64",
                default = true,
              },
            },
          },
          eclipse = { downloadSources = true },
          maven = { downloadSources = true },
          implementationsCodeLens = { enabled = true },
          referencesCodeLens = { enabled = true },
          signatureHelp = { enabled = true },
          format = { enabled = true },
        },
      },
      on_attach = function(client, bufnr)
        -- Setup DAP and main class configurations safely after client attaches
        jdtls.setup_dap({ hotcodereplace = "auto" })
        require("jdtls.dap").setup_dap_main_class_configs()
      end,
    }

    -- 7. Start or attach to the language server
    jdtls.start_or_attach(config)

    -- 8. Buffer-local keymaps
    local ok, wk = pcall(require, "which-key")
    if ok then
      wk.add({
        { "<leader>j", group = "Java", buffer = args.buf },
      })
    end

    local opts = { buffer = args.buf, silent = true }
    vim.keymap.set("n", "<leader>jo", jdtls.organize_imports, vim.tbl_extend("force", opts, { desc = "Organize Imports" }))
    vim.keymap.set("n", "<leader>jv", jdtls.extract_variable, vim.tbl_extend("force", opts, { desc = "Extract Variable" }))
    vim.keymap.set("v", "<leader>jv", function() jdtls.extract_variable(true) end, vim.tbl_extend("force", opts, { desc = "Extract Variable" }))
    vim.keymap.set("n", "<leader>jc", jdtls.extract_constant, vim.tbl_extend("force", opts, { desc = "Extract Constant" }))
    vim.keymap.set("v", "<leader>jm", function() jdtls.extract_method(true) end, vim.tbl_extend("force", opts, { desc = "Extract Method" }))
  end,
})
