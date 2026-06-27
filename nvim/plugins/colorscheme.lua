-- Managed by desktop-theme.py — concept: Ember — warm GitHub (white / orange / coral)
vim.pack.add({ { src = "https://github.com/projekt0n/github-nvim-theme" } })

require("github-theme").setup({
  options = { transparent = true, styles = { comments = "italic" } },
  palettes = { github_dark_default = {
    blue = { base = "#ff8c7a", bright = "#ffb3a3" },
    cyan = { base = "#ffa198", bright = "#ffbcaf" } } },
})

vim.cmd.colorscheme("github_dark_default")
