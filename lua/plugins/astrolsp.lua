-- AstroLSP configuration
-- Format on save and LSP formatting options

---@type LazySpec
return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = {
    -- customize lsp formatting options
    formatting = {
      -- control auto formatting on save
      format_on_save = {
        enabled = true, -- enable format on save globally
        -- No formatear archivos dentro de plugins instalados
        filter = function(bufnr)
          local path = vim.api.nvim_buf_get_name(bufnr)
          local lazy_dir = vim.fn.stdpath "data" .. "/lazy/"
          if path:sub(1, #lazy_dir) == lazy_dir then return false end
          return true
        end,
      },
      disabled = { -- disable formatting capabilities for specific LSPs
        -- "lua_ls",
      },
      timeout_ms = 1000, -- default format timeout
    },
  },
}

