local o = vim.opt

o.number = true
o.relativenumber = true
o.mouse = "a"
o.clipboard = "unnamedplus"
o.ignorecase = true
o.smartcase = true
o.termguicolors = true
o.signcolumn = "yes"
o.cursorline = true
o.laststatus = 3 -- one global statusline shared by all windows
o.fillchars:append({ eob = " " }) -- hide "~" on lines past the end of buffer

o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2
o.smartindent = true

o.wrap = false
o.scrolloff = 5
o.splitright = true
o.splitbelow = true
o.undofile = true
