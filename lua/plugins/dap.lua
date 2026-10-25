-- dap.lua

vim.pack.add({
  "https://github.com/mfussenegger/nvim-dap",
  "https://github.com/nvim-neotest/nvim-nio", -- needed by dap-ui
  "https://github.com/rcarriga/nvim-dap-ui",
  "https://github.com/theHamsta/nvim-dap-virtual-text",
})

local dap = require("dap")
local dapui = require("dapui")

dapui.setup()

-- Show variable values inline next to the code while debugging
require("nvim-dap-virtual-text").setup({
  commented = true, -- show values as comments
})

-- Open the UI when a session starts, close it when it ends
dap.listeners.before.attach.dapui_config = function()
  dapui.open()
end
dap.listeners.before.launch.dapui_config = function()
  dapui.open()
end

-- Close the REPL and program output buffers left behind by a session.
-- (dap-ui's own panel buffers are hidden and reused, so they are kept;
-- dapui.close() already closes their windows.)
local function close_dap_buffers()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) then
      local ft = vim.bo[buf].filetype
      local name = vim.api.nvim_buf_get_name(buf)
      if ft == "dap-repl" or name:match("%[dap%-terminal%]") then
        pcall(vim.api.nvim_buf_delete, buf, { force = true })
      end
    end
  end
end

-- Remove the inline variable values shown by nvim-dap-virtual-text
local function clear_virtual_text()
  local ns = vim.api.nvim_create_namespace("nvim-dap-virtual-text")
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
    end
  end
end

local function on_session_end()
  dapui.close()
  vim.schedule(function()
    clear_virtual_text()
    close_dap_buffers()
  end)
end

dap.listeners.before.event_terminated.dapui_config = on_session_end
dap.listeners.before.event_exited.dapui_config = on_session_end
dap.listeners.after.disconnect.dapui_config = on_session_end


local signs = {
  DapBreakpoint = { text = "\u{f111}", texthl = "DiagnosticError" },
  DapBreakpointCondition = { text = "\u{f059}", texthl = "DiagnosticWarn" },
  DapBreakpointRejected = { text = "\u{f05e}", texthl = "DiagnosticError" },
  DapLogPoint = { text = "\u{f05a}", texthl = "DiagnosticInfo" },
  DapStopped = {
    text = "\u{f061}",
    texthl = "DiagnosticOk",
    linehl = "Visual",
  },
}

for name, sign in pairs(signs) do
  vim.fn.sign_define(name, sign)
end

-- C/C++ with cpp tools
dap.adapters.cppdbg = {
  id = "cppdbg",
  type = "executable",
  command = vim.fn.stdpath("data") .. "/mason/bin/OpenDebugAD7",
}

local function pick_program()
  return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
end

-- Makes gdb show std::string, std::vector etc. nicely
local pretty_printing = {
  {
    text = "-enable-pretty-printing",
    description = "Enable pretty printing",
    ignoreFailures = false,
  },
}

dap.configurations.cpp = {
  {
    name = "Launch",
    type = "cppdbg",
    request = "launch",
    program = pick_program,
    cwd = "${workspaceFolder}",
    stopAtEntry = false,
    MIMode = "gdb",
    miDebuggerPath = "gdb",
    setupCommands = pretty_printing,
  },
  {
    name = "Launch (stop at main)",
    type = "cppdbg",
    request = "launch",
    program = pick_program,
    cwd = "${workspaceFolder}",
    stopAtEntry = true,
    MIMode = "gdb",
    miDebuggerPath = "gdb",
    setupCommands = pretty_printing,
  },
  {
    name = "Attach to running process",
    type = "cppdbg",
    request = "attach",
    program = pick_program,
    processId = require("dap.utils").pick_process,
    MIMode = "gdb",
    miDebuggerPath = "gdb",
    setupCommands = pretty_printing,
  },
  {
    -- For remote/embedded targets: run `gdbserver :1234 ./app` on the target
    name = "Connect to gdbserver",
    type = "cppdbg",
    request = "launch",
    program = pick_program,
    cwd = "${workspaceFolder}",
    MIMode = "gdb",
    miDebuggerPath = "gdb-multiarch",
    miDebuggerServerAddress = function()
      return vim.fn.input("gdbserver address: ", "localhost:1234")
    end,
    setupCommands = pretty_printing,
  },
  {
    -- Bare-metal (STM32 etc.). Start a GDB server first:
    --   OpenOCD:      openocd -f interface/stlink.cfg -f target/stm32f4x.cfg   (port 3333)
    --   ST-LINK:      st-util   (port 4242)
    name = "STM32 (OpenOCD / ST-LINK)",
    type = "cppdbg",
    request = "launch",
    program = function()
      return vim.fn.input("Path to .elf: ", vim.fn.getcwd() .. "/build/", "file")
    end,
    cwd = "${workspaceFolder}",
    MIMode = "gdb",
    miDebuggerPath = "arm-none-eabi-gdb",
    miDebuggerServerAddress = function()
      return vim.fn.input("GDB server address: ", "localhost:3333")
    end,
    targetArchitecture = "arm",
    stopAtConnect = true,
    postRemoteConnectCommands = {
      { text = "monitor reset halt" }, -- stop the chip
      { text = "load" },               -- flash the .elf
      { text = "monitor reset halt" }, -- start fresh from reset
    },
    setupCommands = pretty_printing,
  },
}

-- C uses the same setups as C++
dap.configurations.c = dap.configurations.cpp

---------------------------------------------------------------------------
-- Keymaps
---------------------------------------------------------------------------

local map = vim.keymap.set

-- Running
map("n", "<F5>", dap.continue, { desc = "Debug: start / continue" })
map("n", "<F10>", dap.step_over, { desc = "Debug: step over" })
map("n", "<F11>", dap.step_into, { desc = "Debug: step into" })
map("n", "<F12>", dap.step_out, { desc = "Debug: step out" })

-- Same actions under <leader>d
map("n", "<leader>dc", dap.continue, { desc = "Start / continue" })
map("n", "<leader>do", dap.step_over, { desc = "Step over" })
map("n", "<leader>di", dap.step_into, { desc = "Step into" })
map("n", "<leader>dO", dap.step_out, { desc = "Step out" })
map("n", "<leader>dC", dap.run_to_cursor, { desc = "Run to cursor" })
map("n", "<leader>dl", dap.run_last, { desc = "Run last config" })
map("n", "<leader>dp", dap.pause, { desc = "Pause" })
map("n", "<leader>dt", dap.terminate, { desc = "Stop" })

-- Breakpoints
map("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
map("n", "<leader>dB", function()
  dap.set_breakpoint(vim.fn.input("Condition: "))
end, { desc = "Conditional breakpoint" })
map("n", "<leader>dL", function()
  dap.set_breakpoint(nil, nil, vim.fn.input("Log message: "))
end, { desc = "Log point" })
map("n", "<leader>dx", dap.clear_breakpoints, { desc = "Clear all breakpoints" })

-- UI
map("n", "<leader>du", dapui.toggle, { desc = "Toggle debug UI" })
map("n", "<leader>dr", dap.repl.toggle, { desc = "Toggle REPL" })
map({ "n", "x" }, "<leader>de", dapui.eval, { desc = "Evaluate expression" })
