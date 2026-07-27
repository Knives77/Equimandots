-- DAP (Debug Adapter Protocol) configuration for C/C++
--
-- Tres entornos de debug:
--   1. "Compilar y depurar (clang)"   → archivos individuales con clang nativo
--   2. "Make y depurar"               → proyectos con Makefile (exercism, etc.)
--   3. "ARM: Make + QEMU + GDB"       → proyectos ARM embebido con QEMU

---@type LazySpec
return {
  -- Asegurar que dap-ui se abra/cierre automáticamente
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

      -----------------------------------------------------------------------
      -- Adaptador GDB (para debug ARM remoto vía QEMU)
      -----------------------------------------------------------------------
      dap.adapters.gdb = {
        type = "executable",
        command = "gdb",
        args = { "--interpreter=dap", "--quiet" },
      }

      -----------------------------------------------------------------------
      -- Configuraciones de lanzamiento para C
      -----------------------------------------------------------------------
      dap.configurations.c = {
        --
        -- 1) Archivo individual con clang (proyectos simples)
        --
        {
          name = "Compilar y depurar (clang)",
          type = "codelldb",
          request = "launch",
          program = function()
            local file = vim.fn.expand "%:p"
            local output = vim.fn.expand "%:p:r"
            local cmd = string.format("clang -g -O0 -Wall -Wextra -o %s %s", output, file)
            vim.fn.system(cmd)

            if vim.v.shell_error ~= 0 then
              vim.notify("Error de compilación. Revisa el código.", vim.log.levels.ERROR)
              return nil
            end

            vim.notify("Compilación exitosa: " .. output, vim.log.levels.INFO)
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
        -- 2) Proyectos con Makefile nativo (exercism, etc.)
        --
        {
          name = "Make y depurar",
          type = "codelldb",
          request = "launch",
          program = function()
            local file_dir = vim.fn.expand "%:p:h"
            local makefile = vim.fn.filereadable(file_dir .. "/Makefile") == 1
              or vim.fn.filereadable(file_dir .. "/makefile") == 1

            if not makefile then
              vim.notify("No se encontró Makefile en: " .. file_dir, vim.log.levels.ERROR)
              return nil
            end

            -- Compilar con make (target por defecto)
            local result = vim.fn.system("make -C " .. vim.fn.shellescape(file_dir) .. " 2>&1")
            if vim.v.shell_error ~= 0 then
              vim.notify("Error de compilación:\n" .. result, vim.log.levels.ERROR)
              return nil
            end
            vim.notify("Make exitoso", vim.log.levels.INFO)

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
        -- 3) ARM embebido: Make + QEMU + GDB remoto
        --
        {
          name = "ARM: Make + QEMU + GDB",
          type = "gdb",
          request = "launch",
          program = function()
            local file_dir = vim.fn.expand "%:p:h"

            -- Buscar Makefile
            local has_makefile = vim.fn.filereadable(file_dir .. "/Makefile") == 1
            if not has_makefile then
              vim.notify("No se encontró Makefile en: " .. file_dir, vim.log.levels.ERROR)
              return nil
            end

            -- Compilar con make build
            local result = vim.fn.system("make -C " .. vim.fn.shellescape(file_dir) .. " build 2>&1")
            if vim.v.shell_error ~= 0 then
              vim.notify("Error de compilación:\n" .. result, vim.log.levels.ERROR)
              return nil
            end
            vim.notify("Make build exitoso", vim.log.levels.INFO)

            -- Lanzar QEMU en segundo plano con GDB server (-s = :1234, -S = pausa al inicio)
            local elf = vim.fn.input("ELF generado: ", file_dir .. "/firmware.elf", "file")
            local qemu_cmd = string.format(
              "qemu-system-arm -machine versatilepb -nographic -semihosting -kernel %s -s -S &",
              vim.fn.shellescape(elf)
            )
            vim.fn.system(qemu_cmd)
            -- Dar tiempo a QEMU para arrancar
            vim.fn.system "sleep 0.5"
            vim.notify("QEMU iniciado en :1234", vim.log.levels.INFO)

            return elf
          end,
          cwd = function() return vim.fn.expand "%:p:h" end,
          stopOnEntry = false,
          -- Conectar GDB al servidor QEMU
          setupCommands = {
            { text = "set architecture arm" },
            { text = "target remote :1234" },
          },
        },

        --
        -- 4) Depurar ejecutable existente
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
        -- 5) Attach a proceso
        --
        {
          name = "Attach a proceso",
          type = "codelldb",
          request = "attach",
          pid = require("dap.utils").pick_process,
          cwd = "${workspaceFolder}",
        },
      }

      -- Reutilizar la misma configuración para C++
      dap.configurations.cpp = dap.configurations.c
    end,
  },
}
