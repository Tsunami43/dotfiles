return {
    -- Setup mason-null-ls
    {
        "jayp0521/mason-null-ls.nvim",
        dependencies = { "williamboman/mason.nvim", "nvimtools/none-ls.nvim" },
        config = function()
            require("mason-null-ls").setup({
                ensure_installed = {
                    "ruff",
                    "stylua"
                },
                automatic_installation = true,
            })

            local null_ls = require("null-ls")

            null_ls.setup({
                sources = {
                    -- Python
                    null_ls.builtins.formatting.ruff,
                    null_ls.builtins.diagnostics.ruff,

                    -- Lua
                    null_ls.builtins.formatting.stylua,
                },
            })

            -- Autoformat on save
            vim.api.nvim_create_autocmd("BufWritePre", {
                pattern = { "*.py", "*.lua" },
                callback = function()
                    vim.lsp.buf.format({ async = false })
                end,
            })
        end,
    },
}
