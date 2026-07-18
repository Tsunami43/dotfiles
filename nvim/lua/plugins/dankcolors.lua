return {
	{
		"RRethy/base16-nvim",
		priority = 1000,
		config = function()
			require('base16-colorscheme').setup({
				base00 = '#161b22',
				base01 = '#161b22',
				base02 = '#a59a98',
				base03 = '#a59a98',
				base04 = '#fff1ef',
				base05 = '#fff9f8',
				base06 = '#fff9f8',
				base07 = '#fff9f8',
				base08 = '#ff9c9b',
				base09 = '#ff9c9b',
				base0A = '#ff9d8d',
				base0B = '#b4ffa1',
				base0C = '#ffcbc3',
				base0D = '#ff9d8d',
				base0E = '#ffaea1',
				base0F = '#ffaea1',
			})

			vim.api.nvim_set_hl(0, 'Visual', {
				bg = '#a59a98',
				fg = '#fff9f8',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Statusline', {
				bg = '#ff9d8d',
				fg = '#161b22',
			})
			vim.api.nvim_set_hl(0, 'LineNr', { fg = '#a59a98' })
			vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = '#ffcbc3', bold = true })

			vim.api.nvim_set_hl(0, 'Statement', {
				fg = '#ffaea1',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Keyword', { link = 'Statement' })
			vim.api.nvim_set_hl(0, 'Repeat', { link = 'Statement' })
			vim.api.nvim_set_hl(0, 'Conditional', { link = 'Statement' })

			vim.api.nvim_set_hl(0, 'Function', {
				fg = '#ff9d8d',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Macro', {
				fg = '#ff9d8d',
				italic = true
			})
			vim.api.nvim_set_hl(0, '@function.macro', { link = 'Macro' })

			vim.api.nvim_set_hl(0, 'Type', {
				fg = '#ffcbc3',
				bold = true,
				italic = true
			})
			vim.api.nvim_set_hl(0, 'Structure', { link = 'Type' })

			vim.api.nvim_set_hl(0, 'String', {
				fg = '#b4ffa1',
				italic = true
			})

			vim.api.nvim_set_hl(0, 'Operator', { fg = '#fff1ef' })
			vim.api.nvim_set_hl(0, 'Delimiter', { fg = '#fff1ef' })
			vim.api.nvim_set_hl(0, '@punctuation.bracket', { link = 'Delimiter' })
			vim.api.nvim_set_hl(0, '@punctuation.delimiter', { link = 'Delimiter' })

			vim.api.nvim_set_hl(0, 'Comment', {
				fg = '#a59a98',
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
