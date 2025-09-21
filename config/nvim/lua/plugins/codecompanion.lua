return {
	{
		"olimorris/codecompanion.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			{ "echasnovski/mini.nvim", version = "*" }, -- Для mini.diff
		},
		config = function()
			-- Настройка mini.diff для inline diff
			require("mini.diff").setup({
				view = {
					style = "sign", -- Показывать изменения как знаки
					priority = 199,
				},
				mappings = {
					-- Горячие клавиши для принятия/отклонения изменений
					apply = "gda", -- DiffAccept - принять изменение
					reset = "gdr", -- DiffReject - отклонить изменение
					textobject = "gh", -- Выделить изменение
					goto_first = "[H", -- К первому изменению
					goto_prev = "[h", -- К предыдущему изменению
					goto_next = "]h", -- К следующему изменению
					goto_last = "]H", -- К последнему изменению
				},
			})

			require("codecompanion").setup({
				opts = {
					system_prompt = function(opts)
						return "Отвечай всегда на русском."
					end,
				},
				display = {
					chat = {
						auto_scroll = false,
						keymaps = {
							send = {
								modes = { n = "<C-s>", i = "<C-s>" },
								opts = {},
							},
							close = {
								modes = { n = "<C-c>", i = "<C-c>" },
								opts = {},
							},
						},
						icons = {
							buffer_pin = " ",
							buffer_watch = "👀 ",
						},
						debug_window = {
							width = vim.o.columns - 5,
							height = vim.o.lines - 2,
						},
						token_count = function(tokens, adapter)
							return " (" .. tokens .. " tokens)"
						end,
						window = {
							layout = "vertical",
							position = "right",
							border = "single",
							height = 0.8,
							width = 0.32,
							relative = "editor",
							full_height = true,
							sticky = false,
							opts = {
								breakindent = true,
								cursorcolumn = false,
								cursorline = false,
								foldcolumn = "0",
								linebreak = true,
								list = false,
								numberwidth = 1,
								signcolumn = "no",
								spell = false,
								wrap = true,
							},
						},
					},
					action_palette = {
						width = 95,
						height = 10,
						prompt = "Prompt ",
						provider = "telescope",
						opts = {
							show_default_actions = true,
							show_default_prompt_library = true,
						},
					},
					diff = {
						enabled = true,
						provider = "inline", -- Inline diff прямо в файле
						close_chat_at = 240, -- Close chat buffer if columns < 240
						-- Настройки inline diff
						opts = {
							"internal",
							"filler",
							"closeoff",
							"algorithm:patience",
							"followwrap",
							"linematch:120",
						},
					},
				},
				strategies = {
					chat = {
						adapter = "openai",
						roles = {
							llm = function(adapter)
								return "CodeCompanion (" .. adapter.formatted_name .. ")"
							end,
							user = "Tsunami43",
						},
						-- Настройки tools с approval workflow
						tools = {
							-- Требовать подтверждения для cmd_runner
							cmd_runner = {
								opts = {
									requires_approval = true, -- Подтверждение команд
								},
							},
							-- Требовать подтверждения для редактирования файлов
							insert_edit_into_file = {
								opts = {
									requires_approval = true, -- Подтверждение изменений файлов
								},
							},
						},
						-- Настройки slash commands для контекста
						slash_commands = {
							-- Команда для добавления текущего буфера
							["buffer"] = {
								description = "Добавить содержимое текущего файла",
								callback = "strategies.chat.slash_commands.buffer",
								opts = {
									provider = "default",
									contains_code = true,
								},
							},
							-- Команда для добавления файлов проекта
							["file"] = {
								description = "Выбрать файлы проекта для анализа",
								callback = "strategies.chat.slash_commands.file",
								opts = {
									provider = "telescope", -- Используем telescope для выбора
									contains_code = true,
								},
							},
						},
					},
					inline = {
						adapter = "openai",
						-- Автоматически показывать inline изменения
						opts = {
							-- Показывать diff для всех inline операций
							show_diff = true,
							-- Требовать подтверждения перед применением
							confirm = true,
							-- Автоматически применять изменения после подтверждения
							auto_apply = false,
						},
						-- Горячие клавиши для Super Diff (inline provider)
						keymaps = {
							accept_change = {
								modes = { n = "gda" }, -- DiffAccept - принять изменение
							},
							reject_change = {
								modes = { n = "gdr" }, -- DiffReject - отклонить изменение
							},
							always_accept = {
								modes = { n = "gdy" }, -- DiffYolo - принять все без вопросов
							},
						},
					},
				},
				adapters = {
					openai = function()
						return require("codecompanion.adapters").extend("openai", {
							env = {
								api_key = "cmd:echo $OPENAI_API_KEY",
							},
							model = "gpt-3.5-turbo",
							temperature = 0.7,
							top_p = 1,
						})
					end,
				},
			})

			-- Горячие клавиши для CodeCompanion
			local opts = { noremap = true, silent = true }

			-- Основные команды CodeCompanion
			vim.keymap.set("v", "<leader>ae", "<cmd>CodeCompanionChat<cr>", opts)
			vim.keymap.set("n", "<leader>at", "<cmd>CodeCompanionChat<cr>", opts)

			-- Actions (action palette)
			vim.keymap.set({ "n", "v" }, "<leader>aa", "<cmd>CodeCompanionActions<cr>", opts)

			-- Inline assistant с прямым применением изменений
			vim.keymap.set("v", "<leader>ai", function()
				-- Получаем выделенный текст
				local start_line = vim.fn.line("'<")
				local end_line = vim.fn.line("'>")
				local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
				local selected_text = table.concat(lines, "\n")

				-- Открываем inline assistant для выделенного текста
				vim.cmd("CodeCompanionInline")
			end, opts)

			-- Быстрое inline редактирование
			vim.keymap.set("n", "<leader>ai", function()
				-- Inline редактирование текущей строки
				vim.cmd("CodeCompanionInline")
			end, opts)

			-- Toggle chat buffer
			vim.keymap.set("n", "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", opts)

			-- Быстрое создание агентов с контекстом
			vim.keymap.set("n", "<leader>af", function()
				-- Открываем чат и вызываем агента
				vim.cmd("CodeCompanionChat @{full_stack_dev}")
				-- Добавляем содержимое текущего файла как контекст
				vim.defer_fn(function()
					vim.cmd("CodeCompanionChat /buffer") -- Slash command для добавления буфера
				end, 200)
			end, vim.tbl_extend("force", opts, { desc = "CodeCompanion: Full Stack Dev + Current File" }))

			vim.keymap.set("n", "<leader>ar", function()
				vim.cmd("CodeCompanionChat @{code_reviewer}")
				vim.defer_fn(function()
					vim.cmd("CodeCompanionChat /buffer") -- Slash command для добавления буфера
				end, 200)
			end, vim.tbl_extend("force", opts, { desc = "CodeCompanion: Code Reviewer + Current File" }))

			vim.keymap.set("n", "<leader>ab", function()
				vim.cmd("CodeCompanionChat @{bug_hunter}")
				vim.defer_fn(function()
					vim.cmd("CodeCompanionChat /buffer") -- Slash command для добавления буфера
				end, 200)
			end, vim.tbl_extend("force", opts, { desc = "CodeCompanion: Bug Hunter + Current File" }))

			-- Дополнительные команды с контекстом проекта
			vim.keymap.set("n", "<leader>ap", function()
				-- Анализ всего проекта
				vim.cmd(
					"CodeCompanionChat @{full_stack_dev} Проанализируй весь проект и предложи улучшения"
				)
				vim.defer_fn(function()
					vim.cmd("CodeCompanionChat /file") -- Slash command для добавления файлов проекта
				end, 200)
			end, vim.tbl_extend("force", opts, { desc = "CodeCompanion: Project Analysis" }))

			vim.keymap.set("n", "<leader>at", function()
				-- Чат с контекстом текущего файла
				vim.cmd("CodeCompanionChat")
				vim.defer_fn(function()
					vim.cmd("CodeCompanionChat /buffer") -- Slash command для добавления буфера
				end, 200)
			end, vim.tbl_extend("force", opts, { desc = "CodeCompanion: Chat + Current File" }))

			-- Специальные inline команды для применения изменений
			vim.keymap.set("n", "<leader>ae", function()
				-- Применить все предложенные изменения
				vim.cmd("CodeCompanionInline ApplyAll")
			end, vim.tbl_extend("force", opts, { desc = "CodeCompanion: Apply All Changes" }))

			vim.keymap.set("n", "<leader>ar", function()
				-- Отклонить все предложенные изменения
				vim.cmd("CodeCompanionInline RejectAll")
			end, vim.tbl_extend("force", opts, { desc = "CodeCompanion: Reject All Changes" }))
		end,
	},
	-- Makrdown preview
	{
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"echasnovski/mini.nvim", -- или другой UI-плагин
		},
		ft = { "markdown", "codecompanion" },
	},
}
