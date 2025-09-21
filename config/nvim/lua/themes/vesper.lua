return {
	"datsfilipe/vesper.nvim",
	config = function()
		require("vesper").setup({
			transparent = false, -- фон прозрачный или нет
			italics = {
				comments = true,
				keywords = true,
				functions = true,
				strings = true,
				variables = true,
			},
			overrides = {}, -- кастомные highlight группы
			palette_overrides = {}, -- переопределения цветов
		})
		require("lualine").setup({
			options = {
				theme = "vesper",
			},
		})
		vim.cmd.colorscheme("vesper")
	end,
}
