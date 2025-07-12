return {
    {
        "jayp0521/mason-null-ls.nvim",
        dependencies = { "williamboman/mason.nvim", "nvimtools/none-ls.nvim" },
        config = function()
            require("mason-null-ls").setup({
                ensure_installed = {
                    "stylua",
                },
                automatic_installation = true,
            })

            local null_ls = require("null-ls")

            null_ls.setup({
                sources = {
                    -- Lua
                    null_ls.builtins.formatting.stylua,
                },
            })

            -- Lua
            vim.api.nvim_create_autocmd("BufWritePre", {
                pattern = { "*.lua" },
                callback = function()
                    vim.lsp.buf.format({ async = false })
                end,
            })

            -- Python
            vim.api.nvim_create_autocmd("BufWritePost", {
                pattern = "*.py",
                callback = function()
                    local filepath = vim.api.nvim_buf_get_name(0)

                    if vim.fn.executable("ruff") == 1 then
                        local cmd = string.format("ruff check --fix %q", filepath)
                        local result = vim.fn.system(cmd)
                        print(result)
                    elseif vim.fn.executable("black") == 1 then
                        local cmd = string.format("black %q", filepath)
                        local result = vim.fn.system(cmd)
                        print(result)
                    else
                        return
                    end
                    vim.cmd("checktime")
                end,
            })

            -- Golang
            vim.api.nvim_create_autocmd("BufWritePre", {
                pattern = "*.go",
                callback = function()
                    vim.lsp.buf.format({ async = false })
                end,
            })
        end,
    },
}
