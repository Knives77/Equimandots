-- DAP (Debug Adapter Protocol) configuration for C/C++
-- Debugger: codelldb (LLDB-based)
-- Compiler: clang

-----------------------------------------------------------------------
-- Utilidades
-----------------------------------------------------------------------

--- Ejecuta un comando de shell y muestra la salida en un split inferior.
--- Presiona q para cerrar el buffer.
---@param cmd string comando a ejecutar
---@param title string título para el buffer de salida
---@return boolean success
local function run_and_show(cmd, title)
  local output = vim.fn.system(cmd)
  local success = vim.v.shell_error == 0

  vim.cmd "botright 12new"
  local buf = vim.api.nvim_get_current_buf()
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = "log"
  vim.api.nvim_buf_set_name(buf, "[" .. title .. "]")

  local lines = {
    "═══ " .. title .. " ═══",
    "$ " .. cmd,
    "",
  }
  for _, line in ipairs(vim.split(output, "\n", { trimempty = false })) do
    table.insert(lines, line)
  end
  table.insert(lines, "")
  table.insert(lines, success and "✓ Exitoso (código 0)" or "✗ Error (código " .. vim.v.shell_error .. ")")

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.keymap.set("n", "q", "<cmd>bwipeout<cr>", { buffer = buf, silent = true })
  vim.cmd "wincmd p"

  return success
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
        --
        -- 1) Archivo individual con clang
        --
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

            local success = run_and_show(cmd, "Compilación clang")
            if not success then return nil end
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

        --
        -- 2) Proyectos con Makefile (exercism, etc.)
        --
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

            local cmd = "make -C " .. vim.fn.shellescape(file_dir)
            local success = run_and_show(cmd, "Make build")
            if not success then return nil end

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

        --
        -- 3) Depurar ejecutable existente
        --
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

        --
        -- 4) Attach a proceso
        --
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
