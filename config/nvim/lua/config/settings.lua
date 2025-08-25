-- Line numbers
vim.opt.number = true -- Show line numbers on the left
vim.opt.relativenumber = true -- Show relative line numbers (useful for movement)

-- Mouse support
vim.opt.mouse = "a" -- Enable mouse support in all modes

-- Clipboard
vim.opt.clipboard = "unnamedplus" -- Use system clipboard

-- Search settings
vim.opt.ignorecase = true -- Case insensitive search
vim.opt.smartcase = true -- Case sensitive if search contains uppercase letters
vim.opt.hlsearch = true -- Highlight search results
vim.opt.incsearch = true -- Show search results as you type

-- Indentation
vim.opt.tabstop = 4 -- Tab width in spaces
vim.opt.shiftwidth = 4 -- Number of spaces for auto-indent
vim.opt.expandtab = true -- Convert tabs to spaces
vim.opt.autoindent = true -- Automatically copy indent from previous line
vim.opt.smartindent = true -- Smart indentation for programming

-- Visual settings
vim.opt.termguicolors = true -- Enable 24-bit RGB color support
vim.opt.cursorline = true -- Highlight current line
vim.opt.wrap = false -- Disable line wrapping
vim.opt.scrolloff = 8 -- Keep 8 lines above/below cursor when scrolling
vim.opt.sidescrolloff = 8 -- Keep 8 characters left/right of cursor when scrolling

-- Performance
vim.opt.updatetime = 100 -- Time in milliseconds for updates (faster completion and signature help)
vim.opt.timeoutlen = 500 -- Time to wait for key sequence

-- File handling
vim.opt.swapfile = false -- Disable swap file creation
vim.opt.backup = false -- Disable backup file creation
vim.opt.undofile = true -- Save undo history between sessions
