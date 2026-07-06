-- texlab LSP para LaTeX
-- Provee: autocompletado, diagnósticos, go-to-definition,
-- referencias, document symbols, renombrar, etc.
--
-- Instalar con: :MasonInstall texlab

---@type LazySpec
return {
  {
    "AstroNvim/astrolsp",
    ---@type AstroLSPOpts
    opts = {
      config = {
        texlab = {
          settings = {
            texlab = {
              build = {
                -- No compilar desde texlab, VimTeX ya se encarga
                onSave = false,
                forwardSearchAfter = false,
              },
              forwardSearch = {
                executable = "zathura",
                args = { "--synctex-forward", "%l:1:%f", "%p" },
              },
              chktex = {
                onOpenAndSave = true, -- diagnostics con chktex
              },
              latexindent = {
                modifyLineBreaks = false,
              },
            },
          },
        },
      },
    },
  },
  -- Instalar texlab automáticamente con Mason
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = {
        "texlab",
      },
    },
  },
}
