local function bundles()
  local pkgs = vim.fn.stdpath("data") .. "/mason/packages/"

  local jars = vim.fn.glob(
    pkgs .. "java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar",
    true,
    true
  )

  -- These two jars from java-test break jdtls if loaded as bundles
  local skip = {
    ["com.microsoft.java.test.runner-jar-with-dependencies.jar"] = true,
    ["jacocoagent.jar"] = true,
  }
  for _, jar in ipairs(vim.fn.glob(pkgs .. "java-test/extension/server/*.jar", true, true)) do
    if not skip[vim.fn.fnamemodify(jar, ":t")] then
      table.insert(jars, jar)
    end
  end

  return jars
end

return {
  -- A function, so each project gets its own -data folder.
  -- The short hash stops two projects with the same folder name from clashing.
  cmd = function(dispatchers, config)
    local root = config.root_dir or vim.fn.getcwd()
    local name = vim.fn.fnamemodify(root, ":t") .. "-" .. vim.fn.sha256(root):sub(1, 8)
    local workspace = vim.fn.stdpath("cache") .. "/jdtls/workspace/" .. name

    return vim.lsp.rpc.start({
      "jdtls", -- Mason's bin is on PATH (PATH = "prepend")
      "--java-executable", "/usr/lib/jvm/java-25-openjdk-amd64/bin/java",
      "-data", workspace,
    }, dispatchers, { cwd = root })
  end,

  filetypes = { "java" },

  -- Use the build files / .git root if found; otherwise the file's own folder.
  -- Without a fallback, jdtls gets no project and debugging breaks.
  root_dir = function(bufnr, on_dir)
    local root = vim.fs.root(bufnr, {
      { "mvnw", "gradlew", "settings.gradle", "settings.gradle.kts" },
      { "pom.xml", "build.gradle", "build.gradle.kts" },
      ".git",
    })
    on_dir(root or vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr)))
  end,

  init_options = {
    bundles = bundles(),
    extendedClientCapabilities = require("jdtls").extendedClientCapabilities,
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
          {
            name = "JavaSE-25",
            path = "/usr/lib/jvm/java-25-openjdk-amd64",
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
}
