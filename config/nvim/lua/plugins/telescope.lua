return {
	"nvim-telescope/telescope.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "make",
		},
	},
	config = function()
		local telescope = require("telescope")
		local builtin = require("telescope.builtin")

		telescope.load_extension("fzf")
		telescope.setup({
			defaults = {
				layout_strategy = "horizontal",
				layout_config = {
					horizontal = {
						height = 0.9,
						preview_cutoff = 120,
						prompt_position = "bottom",
						width = 0.9,
						preview_width = 0.5,
					},
				},
				prompt_prefix = "🔍 ",
				selection_caret = "➤ ",
				file_ignore_patterns = {
					"node_modules",
					".git/",
					"%.lock",
					"dist/",
					"build/",
				},
			},
			pickers = {
				git_commits = {
					layout_strategy = "horizontal",
					layout_config = {
						horizontal = {
							height = 0.9,
							width = 0.9,
							preview_width = 0.6, -- More space for diff
							prompt_position = "bottom",
						},
					},
					previewer = true,
				},
				git_bcommits = {
					layout_strategy = "horizontal",
					layout_config = {
						horizontal = {
							height = 0.9,
							width = 0.9,
							preview_width = 0.6, -- More space for diff
							prompt_position = "bottom",
						},
					},
					previewer = true,
				},
				git_status = {
					layout_strategy = "horizontal",
					layout_config = {
						horizontal = {
							height = 0.9,
							width = 0.9,
							preview_width = 0.6, -- More space for diff
							prompt_position = "bottom",
						},
					},
					previewer = true,
				},
				git_branches = {
					layout_strategy = "horizontal",
					layout_config = {
						horizontal = {
							height = 0.7,
							width = 0.8,
							preview_width = 0.5,
							prompt_position = "bottom",
						},
					},
				},
			},
			extensions = {
				fzf = {
					fuzzy = true, -- false will only do exact matching
					override_generic_sorter = true, -- override the generic sorter
					override_file_sorter = true, -- override the file sorter
					case_mode = "smart_case", -- or "ignore_case" or "respect_case"
				},
			},
		})

		-- Hotkeys
		vim.keymap.set("n", "<leader>fw", function()
			builtin.live_grep()
		end, { noremap = true, silent = true, desc = "Search text" })

		vim.keymap.set("n", "<leader>ff", function()
			builtin.find_files()
		end, { noremap = true, silent = true, desc = "Search file" })

		vim.keymap.set("n", "gd", function()
			builtin.lsp_definitions()
		end, { noremap = true, silent = true, desc = "Go to definition" })

		vim.keymap.set("n", "<leader>dt", function()
			builtin.diagnostics()
		end, { noremap = true, silent = true, desc = "Diagnostics Toggle" })

		-- Git commands with telescope
		vim.keymap.set("n", "<leader>gc", function()
			builtin.git_commits()
		end, { noremap = true, silent = true, desc = "Git commits" })

		vim.keymap.set("n", "<leader>gb", function()
			builtin.git_branches()
		end, { noremap = true, silent = true, desc = "Git branches" })

		vim.keymap.set("n", "<leader>gs", function()
			builtin.git_status()
		end, { noremap = true, silent = true, desc = "Git status" })

		vim.keymap.set("n", "<leader>gS", function()
			builtin.git_stash()
		end, { noremap = true, silent = true, desc = "Git stash" })
	end,
}
