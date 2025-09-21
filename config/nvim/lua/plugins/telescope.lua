return {
	"nvim-telescope/telescope.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope-file-browser.nvim",
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "make",
		},
	},
	config = function()
		local telescope = require("telescope")
		local builtin = require("telescope.builtin")
		local actions = require("telescope.actions")
		local fb_actions = require("telescope._extensions.file_browser.actions")

		telescope.setup({
			defaults = {
				wrap_results = true,
				layout_strategy = "horizontal",
				layout_config = { prompt_position = "top" },
				sorting_strategy = "ascending",
				prompt_prefix = "(◔‿◔)  ",
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
				file_browser = {
					path = "%:p:h", -- currently buffer path
					cwd = vim.loop.cwd(),
					hijack_netrw = true,
					git_status = true,
					initial_mode = "normal",
					respect_gitignore = false,
					hidden = true,
					grouped = true,
					mappings = {
						n = {
							["q"] = actions.close, -- close telescope
							["l"] = actions.select_default, -- open file or down path
							["a"] = fb_actions.create, -- create file/folder
							["r"] = fb_actions.rename, -- rename file/folder
							["R"] = fb_actions.toggle_hidden, -- rename file/folder
							["h"] = fb_actions.goto_parent_dir, -- up path
							["H"] = fb_actions.goto_cwd,
						},
					},
				},
			},
		})

		telescope.load_extension("fzf")
		telescope.load_extension("file_browser")

		-- Hotkeys
		vim.keymap.set("n", "<leader>fw", function()
			builtin.live_grep()
		end, { noremap = true, silent = true, desc = "Search text" })

		vim.keymap.set("n", "<leader>e", ":Telescope file_browser<CR>", { desc = "Toggle File Explore" })

		vim.keymap.set("n", "<leader>ff", function()
			builtin.find_files()
		end, { noremap = true, silent = true, desc = "Search file" })

		vim.keymap.set("n", "gd", function()
			builtin.lsp_definitions()
		end, { noremap = true, silent = true, desc = "Go to definition" })

		vim.keymap.set("n", "<leader>dt", function()
			builtin.diagnostics()
		end, { noremap = true, silent = true, desc = "Diagnostics Toggle" })
	end,
}
