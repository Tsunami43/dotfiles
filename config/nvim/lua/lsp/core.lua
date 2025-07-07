return {
    -- Setup mason
    {
        "williamboman/mason.nvim",
        config = function()
            require("mason").setup({
                ui = {
                    icons = {
                        package_installed = "✓",
                        package_pending = "➜",
                        package_uninstalled = "✗",
                    },
                },
            })
        end,
    },
    -- Setup LSP servers
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "williamboman/mason.nvim" },
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = {
                    "pyright",
                    "lua_ls",
                    "rust_analyzer",
                    "ruff",
                },
                automatic_installation = true,
            })
        end,
    },

    {
        "neovim/nvim-lspconfig",
        config = function()
            local lspconfig = require("lspconfig")

            local capabilities = vim.lsp.protocol.make_client_capabilities()
            local on_attach = function(client, bufnr)
                -- Тут можно добавить keymaps и т.п.
            end

            lspconfig.rust_analyzer.setup({
                on_attach = on_attach,
                capabilities = capabilities,
            })

            lspconfig.lua_ls.setup({
                on_attach = on_attach,
                capabilities = capabilities,
            })

            lspconfig.pyright.setup({
                on_attach = on_attach,
                capabilities = capabilities,
                settings = {
                    pyright = {
                        disableOrganizeImports = true, -- если хочешь использовать ruff для импорта
                    },
                    python = {
                        analysis = {
                            ignore = { "*" }, -- игнорируем анализ pyright, если хотим линтить только через ruff
                        },
                    },
                },
            })

            lspconfig.ruff.setup({
                on_attach = on_attach,
                capabilities = capabilities,
                init_options = {
                    settings = {
                        logLevel = "info", -- можно "debug" для подробных логов
                    }
                }
            })

            -- Отключаем hover у Ruff, чтобы Pyright показывал ховер
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup('lsp_attach_disable_ruff_hover', { clear = true }),
                callback = function(args)
                    local client = vim.lsp.get_client_by_id(args.data.client_id)
                    if client and client.name == 'ruff' then
                        client.server_capabilities.hoverProvider = false
                    end
                end,
                desc = 'Disable hover from Ruff LSP',
            })
        end,
    },
}
