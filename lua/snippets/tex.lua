-- ==========================================================
-- LaTeX Snippets para LuaSnip (estilo Gilles Castel)
-- ==========================================================
-- Basado en: https://castel.dev/post/lecture-notes-1/
-- Adaptado de UltiSnips a LuaSnip para Neovim + AstroNvim
-- ==========================================================

local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local d = ls.dynamic_node
local c = ls.choice_node
local r = ls.restore_node
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local rep = require("luasnip.extras").rep
local postfix = require("luasnip.extras.postfix").postfix

-- =====================
-- Helper: math context
-- =====================
-- Detecta si el cursor está en un entorno matemático usando vimtex
local function in_mathzone()
  return vim.fn["vimtex#syntax#in_mathzone"]() == 1
end

local function in_text()
  return not in_mathzone()
end

local function in_comment()
  return vim.fn["vimtex#syntax#in_comment"]() == 1
end

local function in_env(name)
  local is_inside = vim.fn["vimtex#env#is_inside"](name)
  return (is_inside[1] > 0 and is_inside[2] > 0)
end

-- Condición para auto-expand solo en math
local math_condition = {
  condition = in_mathzone,
  show_condition = in_mathzone,
}

local text_condition = {
  condition = in_text,
  show_condition = in_text,
}

-- =====================
-- Autosnippets (se expanden solos, sin Tab)
-- =====================
local autosnippets = {}
-- =====================
-- Snippets normales (necesitan Tab)
-- =====================
local snippets = {}

-- =============================================
-- 1. ENTORNOS
-- =============================================

-- beg → \begin{}...\end{}  (auto-expand al inicio de línea)
table.insert(autosnippets, s({
  trig = "^beg",
  regTrig = true,
  wordTrig = false,
  name = "begin/end environment",
  dscr = "Create a LaTeX environment",
}, fmta([[
\begin{<>}
	<>
\end{<>}
]], { i(1), i(0), rep(1) })))

-- Entornos comunes con trigger rápido
local envs = {
  { "ali",  "align*" },
  { "eq",   "equation" },
  { "eqs",  "equation*" },
  { "gat",  "gather*" },
  { "cas",  "cases" },
  { "enum", "enumerate" },
  { "item", "itemize" },
  { "desc", "description" },
  { "fig",  "figure" },
  { "tab",  "tabular" },
  { "thm",  "theorem" },
  { "lem",  "lemma" },
  { "cor",  "corollary" },
  { "def",  "definition" },
  { "prop", "proposition" },
  { "prf",  "proof" },
  { "rem",  "remark" },
  { "ex",   "example" },
}

for _, env in ipairs(envs) do
  table.insert(snippets, s({
    trig = env[1],
    name = env[2] .. " environment",
    dscr = "Insert " .. env[2] .. " environment",
  }, fmta([[
\begin{<>}
	<>
\end{<>}
]], { t(env[2]), i(0), t(env[2]) })))
end

-- =============================================
-- 2. MATH INLINE Y DISPLAY
-- =============================================

-- mk → $...$ (inline math, smart space)
table.insert(autosnippets, s({
  trig = "mk",
  wordTrig = true,
  name = "Inline math",
  dscr = "Insert inline math $...$",
}, {
  t("$"), i(1), t("$"), i(0),
}))

-- dm → \[...\] (display math)
table.insert(autosnippets, s({
  trig = "dm",
  wordTrig = true,
  name = "Display math",
  dscr = "Insert display math \\[...\\]",
}, fmta([[
\[
	<>
.\]
]], { i(0) })))

-- =============================================
-- 3. SUBÍNDICES (auto-expand, solo en math)
-- =============================================

-- a1 → a_1  (letra seguida de un dígito)
table.insert(autosnippets, s({
  trig = "([A-Za-z])(%d)",
  regTrig = true,
  wordTrig = false,
  name = "Auto subscript",
  dscr = "Auto subscript: a1 → a_1",
  condition = in_mathzone,
  show_condition = in_mathzone,
}, {
  f(function(_, snip) return snip.captures[1] end),
  t("_"),
  f(function(_, snip) return snip.captures[2] end),
}))

-- a_12 → a_{12}  (letra_dígitodígito)
table.insert(autosnippets, s({
  trig = "([A-Za-z])_(%d%d)",
  regTrig = true,
  wordTrig = false,
  name = "Auto subscript2",
  dscr = "Auto subscript: a_12 → a_{12}",
  condition = in_mathzone,
  show_condition = in_mathzone,
}, {
  f(function(_, snip) return snip.captures[1] end),
  t("_{"),
  f(function(_, snip) return snip.captures[2] end),
  t("}"),
}))

-- =============================================
-- 4. SUPERÍNDICES (solo en math)
-- =============================================

-- sr → ^2
table.insert(autosnippets, s({
  trig = "sr",
  wordTrig = false,
  name = "Squared",
  dscr = "^2",
  condition = in_mathzone,
  show_condition = in_mathzone,
}, { t("^2") }))

-- cb → ^3
table.insert(autosnippets, s({
  trig = "cb",
  wordTrig = false,
  name = "Cubed",
  dscr = "^3",
  condition = in_mathzone,
  show_condition = in_mathzone,
}, { t("^3") }))

-- compl → ^{c}
table.insert(autosnippets, s({
  trig = "compl",
  wordTrig = false,
  name = "Complement",
  dscr = "^{c}",
  condition = in_mathzone,
  show_condition = in_mathzone,
}, { t("^{c}") }))

-- td → ^{}
table.insert(autosnippets, s({
  trig = "td",
  wordTrig = false,
  name = "Superscript",
  dscr = "^{...}",
  condition = in_mathzone,
  show_condition = in_mathzone,
}, { t("^{"), i(1), t("}"), i(0) }))

-- invs → ^{-1}
table.insert(autosnippets, s({
  trig = "invs",
  wordTrig = false,
  name = "Inverse",
  dscr = "^{-1}",
  condition = in_mathzone,
  show_condition = in_mathzone,
}, { t("^{-1}") }))

-- =============================================
-- 5. FRACCIONES (solo en math)
-- =============================================

-- // → \frac{}{}
table.insert(autosnippets, s({
  trig = "//",
  wordTrig = false,
  name = "Fraction",
  dscr = "\\frac{}{}",
  condition = in_mathzone,
  show_condition = in_mathzone,
}, fmta([[\frac{<>}{<>}<>]], { i(1), i(2), i(0) })))

-- Fracción con número: 3/ → \frac{3}{}
local function fraction_with_number_condition(line_to_cursor)
  if not in_mathzone() then
    return false
  end

  local before_fraction = line_to_cursor:match("^(.*)%d+/$")
  if not before_fraction then
    return false
  end

  if before_fraction:match("%^%s*$") then
    return false
  end

  if before_fraction:match("%^%s*[%(%{%[]%s*$") then
    return false
  end

  return true
end

table.insert(autosnippets, s({
  trig = "(%d+)/",
  regTrig = true,
  wordTrig = false,
  name = "Fraction with number",
  dscr = "3/ → \\frac{3}{}",
  condition = fraction_with_number_condition,
  show_condition = in_mathzone,
}, {
  t("\\frac{"),
  f(function(_, snip) return snip.captures[1] end),
  t("}{"),
  i(1),
  t("}"),
  i(0),
}))

-- Fracción con expresión: (algo)/ → \frac{algo}{}
table.insert(autosnippets, s({
  trig = "([^%s/]*[%a\\][^%s/]*)/",
  regTrig = true,
  wordTrig = false,
  name = "Fraction with expression",
  dscr = "expr/ → \\frac{expr}{}",
  condition = in_mathzone,
  show_condition = in_mathzone,
}, {
  t("\\frac{"),
  f(function(_, snip) return snip.captures[1] end),
  t("}{"),
  i(1),
  t("}"),
  i(0),
}))

-- =============================================
-- 6. POSTFIX OPERATORS (solo en math)
-- =============================================

-- hat postfix: phat → \hat{p}
table.insert(autosnippets, s({
  trig = "([A-Za-z])hat",
  regTrig = true,
  wordTrig = false,
  name = "Hat postfix",
  dscr = "phat → \\hat{p}",
  condition = in_mathzone,
  show_condition = in_mathzone,
  priority = 100,
}, {
  t("\\hat{"),
  f(function(_, snip) return snip.captures[1] end),
  t("}"),
}))

-- bar postfix: zbar → \overline{z}
table.insert(autosnippets, s({
  trig = "([A-Za-z])bar",
  regTrig = true,
  wordTrig = false,
  name = "Bar postfix",
  dscr = "zbar → \\overline{z}",
  condition = in_mathzone,
  show_condition = in_mathzone,
  priority = 100,
}, {
  t("\\overline{"),
  f(function(_, snip) return snip.captures[1] end),
  t("}"),
}))

-- tilde postfix: xtilde → \tilde{x}
table.insert(autosnippets, s({
  trig = "([A-Za-z])tilde",
  regTrig = true,
  wordTrig = false,
  name = "Tilde postfix",
  dscr = "xtilde → \\tilde{x}",
  condition = in_mathzone,
  show_condition = in_mathzone,
  priority = 100,
}, {
  t("\\tilde{"),
  f(function(_, snip) return snip.captures[1] end),
  t("}"),
}))

-- dot postfix: xdot → \dot{x}
table.insert(autosnippets, s({
  trig = "([A-Za-z])dot",
  regTrig = true,
  wordTrig = false,
  name = "Dot postfix",
  dscr = "xdot → \\dot{x}",
  condition = in_mathzone,
  show_condition = in_mathzone,
  priority = 100,
}, {
  t("\\dot{"),
  f(function(_, snip) return snip.captures[1] end),
  t("}"),
}))

-- ddot postfix: xddot → \ddot{x}
table.insert(autosnippets, s({
  trig = "([A-Za-z])ddot",
  regTrig = true,
  wordTrig = false,
  name = "Double dot postfix",
  dscr = "xddot → \\ddot{x}",
  condition = in_mathzone,
  show_condition = in_mathzone,
  priority = 200,
}, {
  t("\\ddot{"),
  f(function(_, snip) return snip.captures[1] end),
  t("}"),
}))

-- vec postfix: v,. o v., → \vec{v}
table.insert(autosnippets, s({
  trig = "([%a\\]+)([,%.][,%.])",
  regTrig = true,
  wordTrig = false,
  name = "Vector postfix",
  dscr = "v,. or v., → \\vec{v}",
  condition = in_mathzone,
  show_condition = in_mathzone,
}, {
  t("\\vec{"),
  f(function(_, snip) return snip.captures[1] end),
  t("}"),
}))

-- Prefix versions (lower priority)
table.insert(snippets, s({
  trig = "hat",
  name = "Hat prefix",
  dscr = "\\hat{...}",
  condition = in_mathzone,
  show_condition = in_mathzone,
  priority = 10,
}, fmta([[\hat{<>}<>]], { i(1), i(0) })))

table.insert(snippets, s({
  trig = "bar",
  name = "Overline prefix",
  dscr = "\\overline{...}",
  condition = in_mathzone,
  show_condition = in_mathzone,
  priority = 10,
}, fmta([[\overline{<>}<>]], { i(1), i(0) })))

table.insert(snippets, s({
  trig = "tilde",
  name = "Tilde prefix",
  dscr = "\\tilde{...}",
  condition = in_mathzone,
  show_condition = in_mathzone,
  priority = 10,
}, fmta([[\tilde{<>}<>]], { i(1), i(0) })))

table.insert(snippets, s({
  trig = "vec",
  name = "Vector prefix",
  dscr = "\\vec{...}",
  condition = in_mathzone,
  show_condition = in_mathzone,
  priority = 10,
}, fmta([[\vec{<>}<>]], { i(1), i(0) })))

-- =============================================
-- 7. SÍMBOLOS COMUNES (auto-expand, solo en math)
-- =============================================

local math_symbols = {
  -- Flechas
  { "->",   "\\to" },
  { "!>",   "\\mapsto" },
  { "<->",  "\\leftrightarrow" },
  { "=>",   "\\implies" },
  { "=<",   "\\impliedby" },
  { "iff",  "\\iff" },

  -- Relaciones
  { "<=",   "\\leq" },
  { ">=",   "\\geq" },
  { "!=",   "\\neq" },
  { "~=",   "\\approx" },
  { "~~",   "\\sim" },
  { ">>",   "\\gg" },
  { "<<",   "\\ll" },

  -- Conjuntos
  { "cc",   "\\subset" },
  { "cq",   "\\subseteq" },
  { "notin","\\not\\in" },
  { "inn",  "\\in" },
  { "NN",   "\\mathbb{N}" },
  { "ZZ",   "\\mathbb{Z}" },
  { "QQ",   "\\mathbb{Q}" },
  { "RR",   "\\mathbb{R}" },
  { "CC",   "\\mathbb{C}" },
  { "FF",   "\\mathbb{F}" },
  { "HH",   "\\mathbb{H}" },
  { "OO",   "\\emptyset" },

  -- Operaciones
  { "xx",   "\\times" },
  { "**",   "\\cdot" },
  { "||",   "\\mid" },
  { "ooo",  "\\infty" },
  { "pm.",  "\\pm" },
  { "mp.",  "\\mp" },

  -- Lógica
  { "AA",   "\\forall" },
  { "EE",   "\\exists" },
  { "and",  "\\land" },
  { "or",   "\\lor" },
  { "neg",  "\\neg" },

  -- Misceláneos
  { "nabl", "\\nabla" },
  { "del",  "\\partial" },
  { "...",  "\\ldots" },
  { "cdots","\\cdots" },
  { "sq",   "\\sqrt{" },
  { "dag",  "\\dagger" },
}

for _, sym in ipairs(math_symbols) do
  table.insert(autosnippets, s({
    trig = sym[1],
    wordTrig = sym[1]:match("^[%a]+$") ~= nil,
    name = sym[2],
    dscr = sym[1] .. " → " .. sym[2],
    condition = in_mathzone,
    show_condition = in_mathzone,
  }, { t(sym[2]) }))
end

-- =============================================
-- 8. FUNCIONES CON TAB STOPS (solo en math)
-- =============================================

-- lim → \lim_{n \to \infty}
table.insert(autosnippets, s({
  trig = "lim",
  name = "Limit",
  dscr = "\\lim_{n \\to \\infty}",
  condition = in_mathzone,
  show_condition = in_mathzone,
}, fmta([[\lim_{<> \to <>}]], { i(1, "n"), i(2, "\\infty") })))

-- sum → \sum_{n=1}^{\infty}
table.insert(snippets, s({
  trig = "sum",
  name = "Sum",
  dscr = "\\sum_{n=1}^{\\infty}",
  condition = in_mathzone,
  show_condition = in_mathzone,
}, fmta([[\sum_{<>=<>}^{<>}]], { i(1, "n"), i(2, "1"), i(3, "\\infty") })))

-- prod → \prod_{n=1}^{N}
table.insert(snippets, s({
  trig = "prod",
  name = "Product",
  dscr = "\\prod_{n=1}^{N}",
  condition = in_mathzone,
  show_condition = in_mathzone,
}, fmta([[\prod_{<>=<>}^{<>}]], { i(1, "n"), i(2, "1"), i(3, "N") })))

-- int → \int_{a}^{b} ... dx
table.insert(autosnippets, s({
  trig = "dint",
  name = "Definite integral",
  dscr = "\\int_{a}^{b} ... dx",
  condition = in_mathzone,
  show_condition = in_mathzone,
}, fmta([[\int_{<>}^{<>} <> \, d<>]], { i(1, "a"), i(2, "b"), i(3), i(4, "x") })))

-- int → \int ... dx
table.insert(snippets, s({
  trig = "int",
  name = "Integral",
  dscr = "\\int ... dx",
  condition = in_mathzone,
  show_condition = in_mathzone,
}, fmta([[\int <> \, d<>]], { i(1), i(2, "x") })))

-- Funciones comunes: sin, cos, tan, ln, log, exp, etc.
local trig_funcs = {
  "sin", "cos", "tan", "cot", "sec", "csc",
  "arcsin", "arccos", "arctan",
  "sinh", "cosh", "tanh", "coth",
  "ln", "log", "exp", "det", "dim",
  "ker", "deg", "arg", "min", "max",
  "inf", "sup", "gcd", "hom",
}

for _, fn in ipairs(trig_funcs) do
  table.insert(snippets, s({
    trig = fn,
    name = fn,
    dscr = "\\" .. fn,
    condition = in_mathzone,
    show_condition = in_mathzone,
  }, { t("\\" .. fn) }))
end

-- =============================================
-- 9. LETRAS GRIEGAS (;a → \alpha, solo en math)
-- =============================================

local greek = {
  -- Minúsculas
  { ";a",  "\\alpha" },
  { ";b",  "\\beta" },
  { ";g",  "\\gamma" },
  { ";d",  "\\delta" },
  { ";e",  "\\epsilon" },
  { ";ve", "\\varepsilon" },
  { ";z",  "\\zeta" },
  { ";h",  "\\eta" },
  { ";q",  "\\theta" },
  { ";vq", "\\vartheta" },
  { ";i",  "\\iota" },
  { ";k",  "\\kappa" },
  { ";l",  "\\lambda" },
  { ";m",  "\\mu" },
  { ";n",  "\\nu" },
  { ";x",  "\\xi" },
  { ";p",  "\\pi" },
  { ";r",  "\\rho" },
  { ";s",  "\\sigma" },
  { ";t",  "\\tau" },
  { ";u",  "\\upsilon" },
  { ";f",  "\\phi" },
  { ";vf", "\\varphi" },
  { ";c",  "\\chi" },
  { ";y",  "\\psi" },
  { ";w",  "\\omega" },

  -- Mayúsculas
  { ";G",  "\\Gamma" },
  { ";D",  "\\Delta" },
  { ";Q",  "\\Theta" },
  { ";L",  "\\Lambda" },
  { ";X",  "\\Xi" },
  { ";P",  "\\Pi" },
  { ";S",  "\\Sigma" },
  { ";U",  "\\Upsilon" },
  { ";F",  "\\Phi" },
  { ";Y",  "\\Psi" },
  { ";W",  "\\Omega" },
}

for _, g in ipairs(greek) do
  table.insert(autosnippets, s({
    trig = g[1],
    wordTrig = false,
    name = g[2],
    dscr = g[1] .. " → " .. g[2],
    condition = in_mathzone,
    show_condition = in_mathzone,
  }, { t(g[2]) }))
end

-- =============================================
-- 10. TEXT WRAPPERS Y FORMATTING
-- =============================================

-- En texto normal
table.insert(snippets, s({
  trig = "bf",
  name = "Bold text",
  dscr = "\\textbf{...}",
}, fmta([[\textbf{<>}<>]], { i(1), i(0) })))

table.insert(snippets, s({
  trig = "it",
  name = "Italic text",
  dscr = "\\textit{...}",
}, fmta([[\textit{<>}<>]], { i(1), i(0) })))

table.insert(snippets, s({
  trig = "tt",
  name = "Monospace text",
  dscr = "\\texttt{...}",
}, fmta([[\texttt{<>}<>]], { i(1), i(0) })))

table.insert(snippets, s({
  trig = "ul",
  name = "Underline",
  dscr = "\\underline{...}",
}, fmta([[\underline{<>}<>]], { i(1), i(0) })))

-- En math mode
table.insert(snippets, s({
  trig = "bb",
  name = "mathbb",
  dscr = "\\mathbb{...}",
  condition = in_mathzone,
  show_condition = in_mathzone,
}, fmta([[\mathbb{<>}<>]], { i(1), i(0) })))

table.insert(snippets, s({
  trig = "cal",
  name = "mathcal",
  dscr = "\\mathcal{...}",
  condition = in_mathzone,
  show_condition = in_mathzone,
}, fmta([[\mathcal{<>}<>]], { i(1), i(0) })))

table.insert(snippets, s({
  trig = "rm",
  name = "mathrm",
  dscr = "\\mathrm{...}",
  condition = in_mathzone,
  show_condition = in_mathzone,
}, fmta([[\mathrm{<>}<>]], { i(1), i(0) })))

table.insert(snippets, s({
  trig = "frak",
  name = "mathfrak",
  dscr = "\\mathfrak{...}",
  condition = in_mathzone,
  show_condition = in_mathzone,
}, fmta([[\mathfrak{<>}<>]], { i(1), i(0) })))

table.insert(snippets, s({
  trig = "scr",
  name = "mathscr",
  dscr = "\\mathscr{...}",
  condition = in_mathzone,
  show_condition = in_mathzone,
}, fmta([[\mathscr{<>}<>]], { i(1), i(0) })))

-- =============================================
-- 11. DELIMITADORES (solo en math)
-- =============================================

-- lr( → \left( \right)
table.insert(autosnippets, s({
  trig = "lr()",
  wordTrig = false,
  name = "left( right)",
  dscr = "\\left( \\right)",
  condition = in_mathzone,
  show_condition = in_mathzone,
}, fmta([[\left( <> \right)<>]], { i(1), i(0) })))

-- lr[ → \left[ \right]
table.insert(snippets, s({
  trig = "lr[",
  wordTrig = false,
  name = "left[ right]",
  dscr = "\\left[ \\right]",
  condition = in_mathzone,
  show_condition = in_mathzone,
}, fmta([[\left[ <> \right]<>]], { i(1), i(0) })))

-- lr{ → \left\{ \right\}
table.insert(snippets, s({
  trig = "lr{",
  wordTrig = false,
  name = "left{ right}",
  dscr = "\\left\\{ \\right\\}",
  condition = in_mathzone,
  show_condition = in_mathzone,
}, { t("\\left\\{ "), i(1), t(" \\right\\}"), i(0) }))

-- lr| → \left| \right|
table.insert(snippets, s({
  trig = "lr|",
  wordTrig = false,
  name = "left| right|",
  dscr = "\\left| \\right|",
  condition = in_mathzone,
  show_condition = in_mathzone,
}, fmta([[\left| <> \right|<>]], { i(1), i(0) })))

-- lra → \left\langle \right\rangle
table.insert(snippets, s({
  trig = "lra",
  wordTrig = false,
  name = "left angle right angle",
  dscr = "\\left\\langle \\right\\rangle",
  condition = in_mathzone,
  show_condition = in_mathzone,
}, fmta([[\left\langle <> \right\rangle<>]], { i(1), i(0) })))

-- =============================================
-- 12. MATRICES (solo en math)
-- =============================================

table.insert(autosnippets, s({
  trig = "pmat",
  name = "pmatrix",
  dscr = "pmatrix environment",
  condition = in_mathzone,
  show_condition = in_mathzone,
}, fmta([[
\begin{pmatrix}
	<>
\end{pmatrix}
]], { i(0) })))

table.insert(autosnippets, s({
  trig = "bmat",
  name = "bmatrix",
  dscr = "bmatrix environment",
  condition = in_mathzone,
  show_condition = in_mathzone,
}, fmta([[
\begin{bmatrix}
	<>
\end{bmatrix}
]], { i(0) })))

table.insert(autosnippets, s({
  trig = "vmat",
  name = "vmatrix",
  dscr = "vmatrix (determinant)",
  condition = in_mathzone,
  show_condition = in_mathzone,
}, fmta([[
\begin{vmatrix}
	<>
\end{vmatrix}
]], { i(0) })))

-- =============================================
-- 13. MISC SNIPPETS
-- =============================================

-- sec → \section{}
table.insert(snippets, s({
  trig = "sec",
  name = "Section",
  dscr = "\\section{...}",
}, fmta([[\section{<>}<>]], { i(1), i(0) })))

-- ssec → \subsection{}
table.insert(snippets, s({
  trig = "ssec",
  name = "Subsection",
  dscr = "\\subsection{...}",
}, fmta([[\subsection{<>}<>]], { i(1), i(0) })))

-- sssec → \subsubsection{}
table.insert(snippets, s({
  trig = "sssec",
  name = "Subsubsection",
  dscr = "\\subsubsection{...}",
}, fmta([[\subsubsection{<>}<>]], { i(1), i(0) })))

-- chap → \chapter{}
table.insert(snippets, s({
  trig = "chap",
  name = "Chapter",
  dscr = "\\chapter{...}",
}, fmta([[\chapter{<>}<>]], { i(1), i(0) })))

-- pac → \usepackage{}
table.insert(snippets, s({
  trig = "pac",
  name = "Package",
  dscr = "\\usepackage{...}",
}, fmta([[\usepackage{<>}<>]], { i(1), i(0) })))

-- ref → \ref{}
table.insert(snippets, s({
  trig = "ref",
  name = "Reference",
  dscr = "\\ref{...}",
}, fmta([[\ref{<>}<>]], { i(1), i(0) })))

-- eqref → \eqref{}
table.insert(snippets, s({
  trig = "eqref",
  name = "Equation reference",
  dscr = "\\eqref{...}",
}, fmta([[\eqref{<>}<>]], { i(1), i(0) })))

-- lab → \label{}
table.insert(snippets, s({
  trig = "lab",
  name = "Label",
  dscr = "\\label{...}",
}, fmta([[\label{<>}<>]], { i(1), i(0) })))

-- cite → \cite{}
table.insert(snippets, s({
  trig = "cite",
  name = "Citation",
  dscr = "\\cite{...}",
}, fmta([[\cite{<>}<>]], { i(1), i(0) })))

-- footnote → \footnote{}
table.insert(snippets, s({
  trig = "fn",
  name = "Footnote",
  dscr = "\\footnote{...}",
}, fmta([[\footnote{<>}<>]], { i(1), i(0) })))

-- text in math → \text{}
table.insert(snippets, s({
  trig = "txt",
  name = "Text in math",
  dscr = "\\text{...}",
  condition = in_mathzone,
  show_condition = in_mathzone,
}, fmta([[\text{<>}<>]], { i(1), i(0) })))

-- =============================================
-- 14. SYMPY EVALUATION
-- =============================================

-- sym → sympy | sympy (block to evaluate)
table.insert(snippets, s({
  trig = "sym",
  name = "Sympy block",
  dscr = "Sympy evaluation block",
}, { t("sympy "), i(1), t(" sympy"), i(0) }))

-- Evaluate sympy: evaluates when pressing Tab after sympy(.*)sympy
table.insert(snippets, s({
  trig = "sympy(.*)sympy",
  regTrig = true,
  wordTrig = false,
  name = "Evaluate sympy",
  dscr = "Evaluate sympy expression and replace with LaTeX",
}, {
  d(1, function(_, snip)
    local expr = snip.captures[1]
    if expr then
      local ok, result = pcall(function()
        local handle = io.popen('python3 -c "from sympy import *; x,y,z,t = symbols(\'x y z t\'); print(latex(' .. expr:gsub("\\\\", ""):gsub("%^", "**"):gsub("{", "("):gsub("}", ")") .. '))"')
        if handle then
          local output = handle:read("*a"):gsub("%s+$", "")
          handle:close()
          return output
        end
        return expr
      end)
      if ok and result and result ~= "" then
        return sn(nil, { t(result) })
      end
    end
    return sn(nil, { t(expr or "") })
  end),
}))

-- =============================================
-- 15. PLANTILLA DE DOCUMENTO
-- =============================================

table.insert(snippets, s({
  trig = "template",
  name = "Document template",
  dscr = "Basic LaTeX document template",
}, fmta([[
\documentclass[<>]{<>}

\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}
\usepackage{amsmath, amssymb, amsthm}
\usepackage{geometry}
\usepackage{hyperref}

\title{<>}
\author{<>}
\date{<>}

\begin{document}

\maketitle

<>

\end{document}
]], {
  i(1, "12pt"),
  i(2, "article"),
  i(3, "Título"),
  i(4, "Autor"),
  i(5, "\\today"),
  i(0),
})))

-- =============================================
-- REGISTRAR SNIPPETS
-- =============================================
ls.add_snippets("tex", snippets, { key = "tex" })
ls.add_snippets("tex", autosnippets, {
  key = "tex_auto",
  type = "autosnippets",
})

return {}
