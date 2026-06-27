vim.pack.add({
    'https://github.com/nvim-tree/nvim-web-devicons',
    'https://github.com/nvim-lualine/lualine.nvim'
})

require('lualine').setup({
 -- "auto" follows the active colorscheme so it stays in sync on theme swaps.
 options = {theme="auto"}
})
