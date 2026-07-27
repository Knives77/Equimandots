-- DAP (Debug Adapter Protocol) configuration for C/C++
-- Debugger: codelldb (LLDB-based)
-- Compiler: clang

--- Compila y notifica el resultado. Solo muestra errores si falla.
---@param cmd string
---@param title string
---@return boolean success
---@return string output
local function compile(cmd, title)
  local output = vim.fn.system(cmd)
  local success = vim.v.shell_error == 0

  if success then
    vim.notify("✓ " .. title, vim.log.levels.INFO)
  else
    vim.notify("✗ " .. title .. "\n" .. output, vim.log.levels.ERROR)
  end

  return success, output
end

---@type LazySpec
return {
  -- DAP UI auto-open/close
  {
    "rcarriga/nvim-dap-ui",
    opts = function(_, opts)
      local dap = require "dap"
      local dapui = require "dapui"

      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

      return opts
    end,
  },
  {
    "mfussenegger/nvim-dap",
    config = function()
      local dap = require "dap"

      dap.configurations.c = {
        {
          name = "Compilar y depurar (clang)",
          type = "codelldb",
          request = "launch",
          program = function()
            local file = vim.fn.expand "%:p"
            local output = vim.fn.expand "%:p:r"
            local cmd = string.format(
              "clang -g -O0 -Wall -Wextra -o %s %s",
              vim.fn.shellescape(output),
              vim.fn.shellescape(file)
            )

            if not compile(cmd, "Compilación clang") then return nil end
            return output
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
          args = function()
            local input = vim.fn.input "Argumentos (vacío para ninguno): "
            if input == "" then return {} end
            return vim.split(input, " ", { trimempty = true })
          end,
        },
        {
          name = "Make y depurar",
          type = "codelldb",
          request = "launch",
          program = function()
            local file_dir = vim.fn.expand "%:p:h"
            local has_makefile = vim.fn.filereadable(file_dir .. "/Makefile") == 1
              or vim.fn.filereadable(file_dir .. "/makefile") == 1

            if not has_makefile then
              vim.notify("No se encontró Makefile en: " .. file_dir, vim.log.levels.ERROR)
              return nil
            end

            if not compile("make -C " .. vim.fn.shellescape(file_dir), "Make build") then return nil end

            return vim.fn.input("Ejecutable generado: ", file_dir .. "/", "file")
          end,
          cwd = function() return vim.fn.expand "%:p:h" end,
          stopOnEntry = false,
          args = function()
            local input = vim.fn.input "Argumentos (vacío para ninguno): "
            if input == "" then return {} end
            return vim.split(input, " ", { trimempty = true })
          end,
        },
        {
          name = "Depurar ejecutable existente",
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input("Ruta al ejecutable: ", vim.fn.getcwd() .. "/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
          args = function()
            local input = vim.fn.input "Argumentos (vacío para ninguno): "
            if input == "" then return {} end
            return vim.split(input, " ", { trimempty = true })
          end,
        },
        {
          name = "Attach a proceso",
          type = "codelldb",
          request = "attach",
          pid = require("dap.utils").pick_process,
          cwd = "${workspaceFolder}",
        },
      }

      dap.configurations.cpp = dap.configurations.c
    end,
  },
}
