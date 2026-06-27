-- Kanagawa colorscheme: warm, painterly palette with rich treesitter support.
-- Themes: "wave" (default dark), "dragon" (darker/muted), "lotus" (light).
vim.pack.add({
  { src = "https://github.com/rebelot/kanagawa.nvim" },
})

require("kanagawa").setup({
  -- Keep comments low-key but everything else vivid.
  commentStyle = { italic = true },
  keywordStyle = { italic = false },
})

vim.cmd.colorscheme("kanagawa")
