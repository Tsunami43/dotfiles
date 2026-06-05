vim.pack.add({
	{ src = "https://github.com/mikavilpas/yazi.nvim" },
})

require("yazi").setup({
	-- We open yazi explicitly via keymaps, not as a netrw replacement.
	open_for_directories = false,
})

local map = vim.keymap.set
map("n", "<leader>e", "<cmd>Yazi<cr>", { desc = "Yazi at current file" })
map("n", "<leader>-", "<cmd>Yazi<cr>", { desc = "Yazi at current file" })
map("n", "<leader>cw", "<cmd>Yazi cwd<cr>", { desc = "Yazi in cwd" })
map("n", "<C-up>", "<cmd>Yazi toggle<cr>", { desc = "Resume last yazi session" })
