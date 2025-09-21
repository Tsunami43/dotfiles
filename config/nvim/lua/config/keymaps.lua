-- Key mappings configuration

local opts = { noremap = true, silent = true }

-- Undo/Redo (like IDE)
vim.keymap.set("n", "<C-z>", "u", opts) -- Undo (Ctrl+Z)
vim.keymap.set("n", "<C-y>", "<C-r>", opts) -- Redo (Ctrl+Y)

-- Window navigation with Ctrl + hjkl
vim.keymap.set("n", "<C-h>", "<C-w>h", opts) -- Move to window left
vim.keymap.set("n", "<C-j>", "<C-w>j", opts) -- Move to window below
vim.keymap.set("n", "<C-k>", "<C-w>k", opts) -- Move to window above
vim.keymap.set("n", "<C-l>", "<C-w>l", opts) -- Move to window right

-- Window resizing with Ctrl + Shift + arrows
vim.keymap.set("n", "<C-S-Up>", ":resize +2<CR>", opts) -- Increase height
vim.keymap.set("n", "<C-S-Down>", ":resize -2<CR>", opts) -- Decrease height
vim.keymap.set("n", "<C-S-Left>", ":vertical resize -2<CR>", opts) -- Decrease width
vim.keymap.set("n", "<C-S-Right>", ":vertical resize +2<CR>", opts) -- Increase width

-- Split windows with leader + w + hjkl
vim.keymap.set("n", "<leader>wh", "<C-w>v<C-w>h", opts) -- Split left
vim.keymap.set("n", "<leader>wl", "<C-w>v", opts) -- Split right
vim.keymap.set("n", "<leader>wj", "<C-w>s", opts) -- Split down
vim.keymap.set("n", "<leader>wk", "<C-w>s<C-w>k", opts) -- Split up

-- Exit mappings (like IDE)
vim.keymap.set("n", "<C-q>", "<cmd>qa<CR>", opts) -- Quit all (with confirmation)
vim.keymap.set("n", "<leader>qq", "<cmd>qa!<CR>", opts) -- Force quit all

-- Close current buffer/file (like IDE close tab)
vim.keymap.set("n", "<C-c>", "<cmd>close<CR>", opts) -- Close current window (Ctrl+C)

-- Move lines in visual mode
vim.keymap.set("v", "<C-K>", ":m '<-2<CR>gv=gv", opts) -- Move selection up
vim.keymap.set("v", "<C-J>", ":m '>+1<CR>gv=gv", opts) -- Move selection down
vim.keymap.set("v", "<C-H>", "<gv", opts) -- Move selection left (unindent)
vim.keymap.set("v", "<C-L>", ">gv", opts) -- Move selection right (indent)

-- Save shortcuts (like IDE)
vim.keymap.set("n", "<C-s>", "<cmd>w<CR>", opts) -- Save file (Ctrl+S)
vim.keymap.set("i", "<C-s>", "<Esc><cmd>w<CR>a", opts) -- Save in insert mode

-- Format code (configured in LSP)

-- Clear search highlight on Esc (but keep other Esc functionality)
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", opts) -- Clear search highlight
