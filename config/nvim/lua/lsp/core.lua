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
                    "gopls",
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
            local on_attach = function(client, bufnr) end

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
            })

            lspconfig.gopls.setup({
                on_attach = on_attach,
                capabilities = capabilities,
            })
        end,
    },
}
