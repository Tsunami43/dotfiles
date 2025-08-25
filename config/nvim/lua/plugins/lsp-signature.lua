return {
	"ray-x/lsp_signature.nvim",
	event = "VeryLazy",
	opts = {
		floating_window = true, -- show in floating window
		hint_enable = false, -- show inline hints
		handler_opts = {
			border = "rounded",
		},
		-- Additional settings
		bind = true, -- required for auto trigger
		doc_lines = 2, -- max documentation lines
		floating_window_above_cur_line = true, -- show above cursor
		hint_prefix = "🐼 ", -- prefix for inline hints
		hi_parameter = "LspSignatureActiveParameter", -- highlight active parameter
		max_height = 12, -- max window height
		max_width = 80, -- max window width
		transparency = nil, -- window transparency (nil = opaque)
		shadow_blend = 36, -- shadow blend
		shadow_guibg = "Black", -- shadow color
		timer_interval = 200, -- update interval (ms)
		toggle_key = "<M-x>", -- toggle signature help
		select_signature_key = "<M-n>", -- switch between signatures
		move_cursor_key = "<M-p>", -- move cursor key
	},
	config = function(_, opts)
		require("lsp_signature").setup(opts)
	end,
}
