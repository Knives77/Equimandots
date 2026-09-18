-- SQL Language Server (sqls) con conexión inteligente a PostgreSQL
-- Contraseña leída automáticamente de ~/.pgpass (nunca en config)
-- Keybindings bajo <Leader>S (solo activos en archivos .sql)
--
-- Al abrir un .sql, pregunta si quieres conectar a PostgreSQL.
-- <Leader>Sc permite reconectar/cambiar después.

---@type LazySpec
return {
  {
    "nanotee/sqls.nvim",
    ft = { "sql", "mysql", "plsql" },
    config = function()
      local sqls_cmd = vim.fn.stdpath "data" .. "/mason/bin/sqls"
      local connected = false

      -- ── Silenciar mensajes molestos de sqls ("no database connection") ──
      local original_handler = vim.lsp.handlers["window/showMessage"]
      vim.lsp.handlers["window/showMessage"] = function(err, result, ctx, config)
        -- Suprimir mensajes de sqls que son ruido
        if result and result.message and result.message:match "no database connection" then return end
        if original_handler then return original_handler(err, result, ctx, config) end
        -- Fallback por defecto
        if result and result.message then
          local levels = { "ERROR", "WARN", "INFO", "DEBUG" }
          vim.notify(result.message, vim.log.levels[levels[result.type] or "INFO"])
        end
      end

      -- ── Arrancar sqls SIN conexiones (solo sintaxis) ──
      vim.lsp.config("sqls", {
        cmd = { sqls_cmd },
        settings = {
          sqls = {
            connections = {},
          },
        },
      })

      vim.lsp.enable "sqls"

      -- ── Leer contraseña de ~/.pgpass (Go lib/pq no lo soporta) ──
      ---@param host string
      ---@param port string
      ---@param user string
      ---@param dbname string
      ---@return string|nil password
      local function read_pgpass(host, port, user, dbname)
        local path = vim.fn.expand "~/.pgpass"
        if vim.fn.filereadable(path) ~= 1 then return nil end
        for _, line in ipairs(vim.fn.readfile(path)) do
          if not line:match "^#" and line ~= "" then
            local h, p, d, u, pw = line:match "^([^:]*):([^:]*):([^:]*):([^:]*):(.+)$"
            if h and (h == "*" or h == host)
              and (p == "*" or p == port)
              and (d == "*" or d == dbname)
              and (u == "*" or u == user) then
              return pw
            end
          end
        end
        return nil
      end

      -- ── Función para conectar bajo demanda ──
      local function connect_postgresql(dbname)
        dbname = dbname or "unidb"

        local password = read_pgpass("localhost", "5432", "homura", dbname)
        if not password then
          vim.notify("✗ No se encontró entrada en ~/.pgpass para " .. dbname, vim.log.levels.ERROR)
          return
        end

        local new_settings = {
          sqls = {
            connections = {
              {
                driver = "postgresql",
                dataSourceName = string.format(
                  "host=localhost port=5432 user=homura password=%s dbname=%s sslmode=disable",
                  password, dbname
                ),
              },
            },
          },
        }

        -- Actualizar config sin reiniciar el servidor
        local clients = vim.lsp.get_clients { name = "sqls" }
        for _, client in ipairs(clients) do
          client.settings = new_settings
          client:notify("workspace/didChangeConfiguration", { settings = new_settings })
        end

        connected = true
        vim.notify("✓ sqls conectado a PostgreSQL (" .. dbname .. ")", vim.log.levels.INFO)
      end

      -- ── Prompt para elegir BD y conectar ──
      local function prompt_connect()
        -- Intentar obtener la lista de bases de datos usando psql
        local get_dbs_cmd = {
          "psql", "-h", "localhost", "-p", "5432", "-U", "homura", "-d", "postgres",
          "-t", "-c", "SELECT datname FROM pg_database WHERE datistemplate = false;"
        }

        local result = vim.fn.systemlist(get_dbs_cmd)

        if vim.v.shell_error == 0 and #result > 0 then
          local dbs = {}
          for _, db in ipairs(result) do
            local clean_db = vim.trim(db)
            if clean_db ~= "" then
              table.insert(dbs, clean_db)
            end
          end

          if #dbs > 0 then
            table.insert(dbs, 1, "✏️  Escribir manualmente...")
            vim.ui.select(dbs, { prompt = "Selecciona una Base de Datos:" }, function(choice)
              if not choice then return end
              if choice == "✏️  Escribir manualmente..." then
                local dbname = vim.fn.input "Base de datos: "
                if dbname ~= "" then connect_postgresql(dbname) end
              else
                connect_postgresql(choice)
              end
            end)
            return
          end
        end

        -- Fallback si psql falla (ej. VM apagada o sin conexión)
        local dbname = vim.fn.input "Base de datos (Ingreso manual): "
        if dbname ~= "" then connect_postgresql(dbname) end
      end

      -- ── Autocmd para cerrar el resultado con 'Q' ──
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("sqls_output_close", { clear = true }),
        pattern = "sqls_output",
        callback = function(args)
          vim.keymap.set("n", "Q", "<Cmd>close<CR>", { buffer = args.buf, silent = true, desc = "Cerrar resultado SQL" })
        end,
      })

      -- ── Keybindings y prompt al attachar sqls ──
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("sqls_keymaps", { clear = true }),
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client or client.name ~= "sqls" then return end

          local opts = { buffer = args.buf, silent = true }

          vim.keymap.set("n", "<Leader>Sc", prompt_connect,
            vim.tbl_extend("force", opts, { desc = "SQL: Conectar a PostgreSQL" }))

          vim.keymap.set("n", "<Leader>Sd", "<Cmd>SqlsSwitchDatabase<CR>",
            vim.tbl_extend("force", opts, { desc = "SQL: Cambiar base de datos" }))

          vim.keymap.set({ "n", "v" }, "<Leader>Se", ":SqlsExecuteQuery<CR>",
            vim.tbl_extend("force", opts, { desc = "SQL: Ejecutar query" }))

          vim.keymap.set({ "n", "v" }, "<Leader>Sv", ":SqlsExecuteQueryVertical<CR>",
            vim.tbl_extend("force", opts, { desc = "SQL: Ejecutar query (vertical)" }))

          -- Preguntar solo la primera vez que se abre un .sql
          if not connected then
            vim.ui.select(
              { "PostgreSQL", "Solo sintaxis" },
              { prompt = "sqls — ¿Cómo iniciar?" },
              function(choice)
                if choice == "PostgreSQL" then
                  prompt_connect()
                end
              end
            )
          end
        end,
      })
    end,
  },
}
