-- Customize Treesitter
-- --------------------
-- Treesitter customizations are handled with AstroCore
-- as nvim-treesitter simply provides a download utility for parsers

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    treesitter = {
      -- Disable all treesitter features for latex
      -- This function disables highlight, indent, and auto_install for latex
      enabled = function(lang, bufnr)
        if lang == "latex" then return false end
        return not require("astrocore.buffer").is_large(bufnr)
      end,
      highlight = true, -- enable treesitter based highlighting
      indent = true, -- enable treesitter based indentation
      auto_install = true, -- enable automatic installation of detected languages
      ensure_installed = {
        "lua",
        "vim",
        -- add more arguments for adding more treesitter parsers
      },
    },
  },
}
