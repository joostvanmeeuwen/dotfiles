return {
  "tidalcycles/vim-tidal",
  ft = "tidal", -- Lazy load alleen voor .tidal bestanden
  config = function()
    vim.g.tidal_target = "terminal"
  end,
}
