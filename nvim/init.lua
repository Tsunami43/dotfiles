-- Leader keys must be set before any plugin loads.
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- No lua/ dir, so load files by absolute path via dofile() instead of require().
local root = vim.fn.stdpath("config")

dofile(root .. "/options.lua")
dofile(root .. "/keymaps.lua")

-- Load every plugin spec under plugins/ (one plugin per file).
local files = vim.fn.globpath(root .. "/plugins", "*.lua", false, true)
table.sort(files)
for _, file in ipairs(files) do
  dofile(file)
end

-- Run every per-language LSP file under lsp/*.lua. Each file is responsible
-- for vim.lsp.config(...) + vim.lsp.enable(...) and any language-specific
-- autocmds (formatting, etc.). No "return" needed.
local lsp_files = vim.fn.globpath(root .. "/lsp", "*.lua", false, true)
table.sort(lsp_files)
for _, file in ipairs(lsp_files) do
  dofile(file)
end
