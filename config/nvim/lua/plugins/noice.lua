return {
	"folke/noice.nvim",
	event = "VeryLazy",
	dependencies = {
		"MunifTanjim/nui.nvim",
		"rcarriga/nvim-notify",
	},
	opts = {
		-- Настройки для noice
		-- Можно здесь прописать notify, чтобы убрать предупреждение о фоне
		notify = {
			-- Указываем цвет фона для уведомлений
			background_colour = "#1e1e2e", -- или "Normal" для фоновой группы темы
		},
	},
	config = function(_, opts)
		local noice = require("noice")

		-- setup с опциями
		noice.setup(opts)

		-- Keymap для закрытия уведомлений
		vim.keymap.set("n", "<Esc>", "<Cmd>Noice dismiss<CR>", { noremap = true, silent = true })
	end,
}
