-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Disable ctrl+b
vim.keymap.set({ "n", "v", "i" }, "<C-b>", "<Nop>", { noremap = true, silent = true })
