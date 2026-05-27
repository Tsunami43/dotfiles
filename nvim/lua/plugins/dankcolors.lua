return {
	{
		"RRethy/base16-nvim",
		priority = 1000,
		config = function()
			require('base16-colorscheme').setup({
				base00 = '#12262b',
				base01 = '#12262b',
				base02 = '#768283',
				base03 = '#768283',
				base04 = '#a8b7b8',
				base05 = '#f5feff',
				base06 = '#f5feff',
				base07 = '#f5feff',
				base08 = '#ed6696',
				base09 = '#ed6696',
				base0A = '#45bac1',
				base0B = '#63d36d',
				base0C = '#a2f1f6',
				base0D = '#45bac1',
				base0E = '#6bdde4',
				base0F = '#6bdde4',
			})

			vim.api.nvim_set_hl(0, 'Visual', {
				bg = '#768283',
				fg = '#f5feff',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Statusline', {
				bg = '#45bac1',
				fg = '#12262b',
			})
			vim.api.nvim_set_hl(0, 'LineNr', { fg = '#768283' })
			vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = '#a2f1f6', bold = true })

			vim.api.nvim_set_hl(0, 'Statement', {
				fg = '#6bdde4',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Keyword', { link = 'Statement' })
			vim.api.nvim_set_hl(0, 'Repeat', { link = 'Statement' })
			vim.api.nvim_set_hl(0, 'Conditional', { link = 'Statement' })

			vim.api.nvim_set_hl(0, 'Function', {
				fg = '#45bac1',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Macro', {
				fg = '#45bac1',
				italic = true
			})
			vim.api.nvim_set_hl(0, '@function.macro', { link = 'Macro' })

			vim.api.nvim_set_hl(0, 'Type', {
				fg = '#a2f1f6',
				bold = true,
				italic = true
			})
			vim.api.nvim_set_hl(0, 'Structure', { link = 'Type' })

			vim.api.nvim_set_hl(0, 'String', {
				fg = '#63d36d',
				italic = true
			})

			vim.api.nvim_set_hl(0, 'Operator', { fg = '#a8b7b8' })
			vim.api.nvim_set_hl(0, 'Delimiter', { fg = '#a8b7b8' })
			vim.api.nvim_set_hl(0, '@punctuation.bracket', { link = 'Delimiter' })
			vim.api.nvim_set_hl(0, '@punctuation.delimiter', { link = 'Delimiter' })

			vim.api.nvim_set_hl(0, 'Comment', {
				fg = '#768283',
				italic = true
			})

			local current_file_path = vim.fn.stdpath("config") .. "/lua/plugins/dankcolors.lua"
			if not _G._matugen_theme_watcher then
				local uv = vim.uv or vim.loop
				_G._matugen_theme_watcher = uv.new_fs_event()
				_G._matugen_theme_watcher:start(current_file_path, {}, vim.schedule_wrap(function()
					local new_spec = dofile(current_file_path)
					if new_spec and new_spec[1] and new_spec[1].config then
						new_spec[1].config()
						print("Theme reload")
					end
				end))
			end
		end
	}
}
