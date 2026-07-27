-- C/C++ LSP configuration (clangd)
-- Provides: autocompletado, diagnósticos, go-to-definition, clang-tidy, formateo

---@type LazySpec
return {
  {
    "AstroNvim/astrolsp",
    ---@type AstroLSPOpts
    opts = {
      -- Registrar clangd para que AstroNvim lo active automáticamente
      servers = { "clangd" },
      -- Configuración específica de clangd
      config = {
        clangd = {
          cmd = {
            "clangd",
            "--background-index", -- indexar en segundo plano
            "--clang-tidy", -- activar diagnósticos de clang-tidy
            "--header-insertion=iwyu", -- include what you use
            "--completion-style=detailed", -- completions detalladas
            "--fallback-style=llvm", -- estilo de formateo por defecto
          },
          capabilities = {
            offsetEncoding = { "utf-16" }, -- fix para offset encoding
          },
        },
      },
      -- Formateo para archivos C/C++
      formatting = {
        format_on_save = {
          enabled = true,
          allow_filetypes = {
            "c",
            "cpp",
          },
        },
      },
    },
  },
}
