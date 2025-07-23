return {
    {
        "olimorris/codecompanion.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            { "echasnovski/mini.nvim", version = "*" },
        },
        config = function()
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
                        close_chat_at = 240, -- Close an open chat buffer if the total columns of your display are less than...
                        layout = "vertical", -- vertical|horizontal split for default provider
                        opts = {
                            "internal",
                            "filler",
                            "closeoff",
                            "algorithm:patience",
                            "followwrap",
                            "linematch:120",
                        },
                        provider = "default", -- default|mini_diff
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
                    },
                    inline = {
                        adapter = "openai",
                    },
                    cmd = {
                        adapter = "openai",
                        cmd_runner = {
                            opts = {
                                requires_approval = true,
                            },
                        },
                    },
                    opts = {
                        completion_provider = "cmp",
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
    vim.api.nvim_set_keymap(
        "v",
        "<leader>ae",
        ":'<,'>CodeCompanionChat<CR>",
        { noremap = true, silent = true }
    ),
    vim.api.nvim_set_keymap(
        "n",
        "<leader>at",
        ":CodeCompanionChat<CR>",
        { noremap = true, silent = true }
    ),
}
