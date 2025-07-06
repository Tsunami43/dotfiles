-- General Neovim settings

vim.o.clipboard = "unnamedplus" -- Use system clipboard
vim.o.textwidth = 80 -- Maximum text width
vim.o.wrap = true -- Enable visual line wrapping
vim.o.number = true -- Show line numbers
vim.o.shiftwidth = 4 -- Indent width when using tabs
vim.o.expandtab = true -- Convert tabs to spaces
vim.o.smartindent = true -- Enable smart indentation
vim.o.swapfile = false -- Disable swap file creation
vim.o.backup = false -- Disable backup file creation
vim.o.hlsearch = true -- Highlight search results
vim.o.ignorecase = true -- Ignore case in search
vim.o.smartcase = true -- Override ignorecase if search contains uppercase letters

-- Performance settings

vim.o.updatetime = 300 -- Time in ms to trigger CursorHold & LSP updates
vim.o.timeoutlen = 500 -- Timeout length for mapped sequences
vim.o.termguicolors = true -- Enable 24-bit RGB color in terminal
-- vim.o.scrolloff = 5 -- Minimum lines to keep above/below the cursor
vim.o.sidescrolloff = 15 -- Minimum columns to keep left/right of the cursor

vim.o.formatoptions = vim.o.formatoptions:gsub("t", "") -- Disable auto line wrapping in insert mode

-- Cursor line highlight & customization

vim.o.cursorline = true -- Highlight the current line
vim.cmd("highlight CursorLineNr guifg=#ffcc00") -- Set yellow color for current line number

-- Global statusline for all windows

vim.opt.laststatus = 3 -- Use a single global statusline (Neovim 0.7+)

-- Remove ~ characters on empty lines at end of buffer

vim.opt.fillchars:append({ eob = " " }) -- Replace end-of-buffer tildes with spaces
