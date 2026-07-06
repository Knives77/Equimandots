-- ==========================================================
-- Configuración de LuaSnip para snippets de LaTeX
-- ==========================================================
-- Carga los snippets custom y configura auto-expand

---@type LazySpec
return {
  "L3MON4D3/LuaSnip",
  config = function(plugin, opts)
    -- Incluir la configuración default de AstroNvim
    require("astronvim.plugins.configs.luasnip")(plugin, opts)

    -- Configurar LuaSnip
    local luasnip = require("luasnip")

    -- Habilitar autosnippets (se expanden sin Tab)
    luasnip.config.setup({
      enable_autosnippets = true,
      -- Actualizar snippets al escribir (para regex y dinámicos)
      update_events = { "TextChanged", "TextChangedI" },
      -- Eliminar snippets al salir de ellos
      delete_check_events = "TextChanged",
      -- Region check type (para que funcione bien con vimtex)
      region_check_events = "InsertEnter",
    })

    -- Cargar snippets de LaTeX
    require("snippets.tex")

    -- Extender filetype: plaintex y latex usan los mismos snippets
    luasnip.filetype_extend("plaintex", { "tex" })
    luasnip.filetype_extend("latex", { "tex" })
  end,
}
