-- Cendre · hard. The same palette the terminal, tmux and the rest now draw from.
vim.pack.add({ { src = "https://github.com/Aejkatappaja/cendre" } })

require("cendre").setup({
  background = "hard",
  -- The ground stays the terminal's, so ghostty's blur carries through the
  -- buffer. tmux is the one surface that paints its own, and only in the bar.
  transparent = true,
})

vim.cmd.colorscheme("cendre")
