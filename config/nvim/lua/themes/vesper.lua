return {
	"datsfilipe/vesper.nvim",
	config = function()
		require("vesper").setup({
			transparent = true, -- фон прозрачный или нет
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
		-- require("lualine").setup({
		-- 	options = {
		-- 		theme = "vesper",
		-- 	},
		-- })
	end,
}
