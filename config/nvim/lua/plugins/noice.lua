return {
	"folke/noice.nvim",
	event = "VeryLazy",
	opts = {},
	dependencies = {
		"MunifTanjim/nui.nvim",
		"rcarriga/nvim-notify",
	},
	config = function()
		local noice = require("noice")

		noice.setup({})

		vim.api.nvim_set_keymap("n", "<Esc>", "<Cmd>Noice dismiss<CR>", { noremap = false, silent = true })
	end,
}
