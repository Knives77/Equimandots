-- DAP (Debug Adapter Protocol) configuration for C/C++ and Bash
-- Debuggers: codelldb (LLDB-based) for C/C++, bash-debug-adapter for Bash
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

--- Opciones comunes de bashdb para no repetirlas en cada configuración
local mason_data = vim.fn.stdpath "data" .. "/mason"
local bashdb_common = {
  type = "bashdb",
  request = "launch",
  pathBashdb = mason_data .. "/packages/bash-debug-adapter/extension/bashdb_dir/bashdb",
  pathBashdbLib = mason_data .. "/packages/bash-debug-adapter/extension/bashdb_dir",
  pathBash = "bash",
  pathCat = "cat",
  pathMkfifo = "mkfifo",
  pathPkill = "pkill",
  env = {},
  terminalKind = "integrated",
}

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

      -- ══════════════════════════════════════════
      -- C/C++ configurations (codelldb)
      -- ══════════════════════════════════════════
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

      -- ══════════════════════════════════════════
      -- Bash configurations (bash-debug-adapter)
      -- ══════════════════════════════════════════
      dap.adapters.bashdb = {
        type = "executable",
        command = mason_data .. "/bin/bash-debug-adapter",
      }

      dap.configurations.sh = {
        -- 1) Script sin argumentos: lanza directo, sin preguntar nada
        vim.tbl_extend("force", bashdb_common, {
          name = "Depurar script (sin argumentos)",
          program = "${file}",
          cwd = "${fileDirname}",
          args = {},
        }),

        -- 2) Script con argumentos: pregunta por $@
        vim.tbl_extend("force", bashdb_common, {
          name = "Depurar script (con argumentos)",
          program = "${file}",
          cwd = "${fileDirname}",
          args = function()
            local input = vim.fn.input "Argumentos: "
            if input == "" then return {} end
            return vim.split(input, " ", { trimempty = true })
          end,
        }),

        -- 3) Elegir archivo + argumentos
        vim.tbl_extend("force", bashdb_common, {
          name = "Depurar script (elegir archivo)",
          program = function()
            return vim.fn.input("Ruta al script: ", vim.fn.getcwd() .. "/", "file")
          end,
          cwd = "${workspaceFolder}",
          args = function()
            local input = vim.fn.input "Argumentos: "
            if input == "" then return {} end
            return vim.split(input, " ", { trimempty = true })
          end,
        }),
      }

      dap.configurations.bash = dap.configurations.sh
    end,
  },
}

