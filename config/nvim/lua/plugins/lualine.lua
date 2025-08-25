return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		require("lualine").setup({
			options = {
				theme = "catppuccin",
				globalstatus = true,
				component_separators = { left = "|", right = "|" },
				section_separators = { left = "", right = "" },
				disabled_filetypes = {
					statusline = {},
					winbar = {},
				},
				always_divide_middle = true,
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = {
					"branch",
					{
						"diff",
						symbols = { added = "+", modified = "~", removed = "-" },
					},
					{
						"diagnostics",
						sources = { "nvim_diagnostic" },
						symbols = { error = "E", warn = "W", info = "I", hint = "H" },
					},
				},
				lualine_c = {
					{
						"filename",
						file_status = true,
						path = 1, -- Relative path
					},
				},
				lualine_x = {
					{
						function()
							local clients = vim.lsp.get_clients()
							if next(clients) == nil then
								return ""
							end
							local c = {}
							for _, client in pairs(clients) do
								table.insert(c, client.name)
							end
							return "⚙ " .. table.concat(c, ",")
						end,
					},
					"encoding",
					"fileformat",
					"filetype",
				},
				lualine_y = { "progress" },
				lualine_z = { "location" },
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = { "filename" },
				lualine_x = { "location" },
				lualine_y = {},
				lualine_z = {},
			},
			extensions = { "neo-tree" },
		})
	end,
}
