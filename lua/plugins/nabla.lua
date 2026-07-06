-- ==========================================================
-- nabla.nvim - Preview de ecuaciones LaTeX inline
-- ==========================================================
-- Renderiza ecuaciones como ASCII art en el buffer
-- Uso: ,lp para toggle preview

---@type LazySpec
return {
  "jbyuki/nabla.nvim",
  ft = { "tex", "latex", "markdown" },
  keys = {
    {
      ",lp",
      function() require("nabla").popup() end,
      desc = "Preview ecuación LaTeX",
      ft = { "tex", "latex", "markdown" },
    },
  },
}
