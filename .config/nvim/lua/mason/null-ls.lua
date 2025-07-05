return {
    -- Setup mason-null-ls
    {
        "jayp0521/mason-null-ls.nvim",
        dependencies = { "williamboman/mason.nvim", "nvimtools/none-ls.nvim" },
        config = function()
            require("mason-null-ls").setup({
                ensure_installed = {
                    "black", -- Formatter for Python
                    "stylua", -- Formatter for Lua
                },
                automatic_installation = true,
            })
            local null_ls = require("null-ls")

            null_ls.setup({
                sources = {
                    null_ls.builtins.formatting.black, -- Formatter for Python
                    null_ls.builtins.formatting.stylua, -- Formatter for Lua
                },
            })
            -- Setup autoformat on save
            vim.api.nvim_create_autocmd("BufWritePre", {
                pattern = { "*.py", "*.lua" },
                callback = function()
                    vim.lsp.buf.format({ async = false })
                    vim.cmd("write")
                end,
            })
        end,
    },
}
