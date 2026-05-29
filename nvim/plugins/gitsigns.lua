-- gitsigns.nvim: per-line git change indicators + hunk actions.
vim.pack.add({
	{ src = "https://github.com/lewis6991/gitsigns.nvim" },
})

require("gitsigns").setup({
	-- Diff-style signs in the signcolumn (clearer than the default thin bars).
	signs = {
		add = { text = "+" },
		change = { text = "~" },
		delete = { text = "-" },
		topdelete = { text = "‾" },
		changedelete = { text = "≃" },
		untracked = { text = "?" },
	},

	-- Buffer-local keymaps are set after the plugin attaches to a tracked file.
	on_attach = function(buf)
		local gs = require("gitsigns")
		local function map(modes, lhs, rhs, desc)
			vim.keymap.set(modes, lhs, rhs, { buffer = buf, desc = desc })
		end

		-- Hunk navigation
		map("n", "<leader>gn", function()
			gs.nav_hunk("next")
		end, "Next git hunk")
		map("n", "<leader>gN", function()
			gs.nav_hunk("prev")
		end, "Previous git hunk")

		-- Hunk actions (normal mode: hunk at cursor; visual mode: selected range)
		map({ "n", "v" }, "<leader>gs", ":Gitsigns stage_hunk<CR>", "Stage hunk")
		map({ "n", "v" }, "<leader>gr", ":Gitsigns reset_hunk<CR>", "Reset hunk")
		map("n", "<leader>gp", gs.preview_hunk, "Preview hunk")

		-- Blame
		map("n", "<leader>gb", function()
			gs.blame_line({ full = true })
		end, "Blame line")
		map("n", "<leader>gB", gs.toggle_current_line_blame, "Toggle inline blame")

		-- Diff against the index: gs.diffthis opens the "before" version in a
		-- new left split, the working buffer stays on the right and keeps focus.
		map("n", "<leader>gd", gs.diffthis, "Diff this file")
	end,
})
