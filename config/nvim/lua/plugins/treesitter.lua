return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter.configs").setup({
			ensure_installed = { "lua", "elixir", "heex", "eex" }, -- добавляем elixir
			highlight = {
				enable = true,
			},
		})
	end,
}
