return {
  "lervag/vimtex",
  lazy = false,     -- we don't want to lazy load VimTeX
  -- tag = "v4.15", -- uncomment to pin to a specific release
  init = function()
    -- 1. Sabor de TeX
    vim.g.tex_flavor = "latex"
    -- 2. Visor de PDF
    vim.g.vimtex_view_method = "zathura"
    -- 3. Modo de la ventana de errores (0 = no abrir automáticamente)
    vim.g.vimtex_quickfix_mode = 0
    -- 4. Opciones de reemplazo visual (conceal)
    vim.g.tex_conceal = "abdmg"

    -- 5. Compilación optimizada
    vim.g.vimtex_compiler_latexmk = {
      out_dir = "build",  -- archivos de compilación van a build/
      options = {
        "-verbose",
        "-file-line-error",
        "-synctex=1",
        "-interaction=nonstopmode",
      },
    }

    -- 6. Forward search apunta a build/
    vim.g.vimtex_view_forward_search_on_start = true
  end,
  config = function()
    -- 7. Activar el nivel de ocultamiento
    vim.opt.conceallevel = 1

    -- 8. Spell check dinámico por carpeta
    -- Si la ruta contiene /en/ o /english/ → inglés
    -- Si la ruta contiene /es/ o /español/ → español
    -- Default → ambos idiomas
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "tex", "latex", "plaintex" },
      callback = function()
        vim.opt_local.spell = true
        local filepath = vim.fn.expand("%:p")
        if filepath:match("/en/") or filepath:match("/english/") then
          vim.opt_local.spelllang = "en_us"
        elseif filepath:match("/es/") or filepath:match("/español/") or filepath:match("/espanol/") then
          vim.opt_local.spelllang = "es"
        else
          vim.opt_local.spelllang = { "es", "en_us" }
        end
      end,
    })

    -- 9. Ctrl+L para corregir el error ortográfico anterior (en insert mode)
    -- Salta al error anterior [s, elige la primera sugerencia 1z=, regresa `]a
    vim.keymap.set("i", "<C-l>", "<c-g>u<Esc>[s1z=`]a<c-g>u", {
      desc = "Corregir error ortográfico anterior",
      buffer = false,
    })

    -- 10. Hacer forward search (o abrir visor) SOLO cuando la compilación termine con éxito
    vim.api.nvim_create_autocmd("User", {
      pattern = "VimtexEventCompileSuccess",
      callback = function()
        vim.cmd("silent! VimtexView")
      end,
    })
  end
}
