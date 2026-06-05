local map = vim.keymap.set

-- General keymaps (plugin-specific ones live in their plugins/*.lua files).

-- Disable Ctrl+b (carried over from the old config).
map({ "n", "v", "i" }, "<C-b>", "<Nop>", { noremap = true, silent = true })

-- Reload the whole config (re-run init.lua). dofile() has no module cache,
-- so every options/keymaps/plugins file is re-sourced fresh.
map("n", "<leader>r", function()
  dofile(vim.fn.stdpath("config") .. "/init.lua")
  vim.notify("Config reloaded", vim.log.levels.INFO)
end, { desc = "Reload config" })

-- Windows --------------------------------------------------------------------

-- Move focus between windows: <leader>w + hjkl. Uses wincmd so it is not
-- affected by the <C-w> + hjkl remaps below.
map("n", "<leader>wh", "<cmd>wincmd h<cr>", { desc = "Go to left window" })
map("n", "<leader>wj", "<cmd>wincmd j<cr>", { desc = "Go to lower window" })
map("n", "<leader>wk", "<cmd>wincmd k<cr>", { desc = "Go to upper window" })
map("n", "<leader>wl", "<cmd>wincmd l<cr>", { desc = "Go to right window" })
map("n", "<leader>wq", "<cmd>close<cr>", { desc = "Close window" })

-- Create a split: <leader>w + v (vertical) / V (horizontal).
map("n", "<leader>wv", "<cmd>vsplit<cr>", { desc = "Split vertically" })
map("n", "<leader>wV", "<cmd>split<cr>", { desc = "Split horizontally" })

-- <Esc> in normal mode: clear search highlight and dismiss popup messages
-- (noice cmdline / nvim-notify toasts) so one tap cleans the screen.
map("n", "<Esc>", function()
	vim.cmd("nohlsearch")
	pcall(vim.cmd, "NoiceDismiss")
	local ok, notify = pcall(require, "notify")
	if ok then
		notify.dismiss({ silent = true, pending = true })
	end
end, { desc = "Clear hlsearch and popups" })

-- Briefly highlight yanked text for visual feedback (0.5s).
vim.api.nvim_create_autocmd("TextYankPost", {
	group = vim.api.nvim_create_augroup("user_yank_highlight", { clear = true }),
	callback = function()
		vim.hl.on_yank({ timeout = 500 })
	end,
})
