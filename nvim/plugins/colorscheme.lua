-- Cendre · hard. The same palette the terminal, tmux and the rest now draw from.
vim.pack.add({ { src = "https://github.com/Aejkatappaja/cendre" } })

require("cendre").setup({
  background = "hard",
  -- The editor paints its own ground now that the terminal is opaque. Left
  -- transparent, floats and the cursorline would inherit whatever sits behind
  -- them instead of the layer the theme puts them on.
  transparent = false,
})

vim.cmd.colorscheme("cendre")
