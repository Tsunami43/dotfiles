return {
    {
        "jayp0521/mason-null-ls.nvim",
        dependencies = { "williamboman/mason.nvim", "nvimtools/none-ls.nvim" },
        config = function()
            require("mason-null-ls").setup({
                ensure_installed = {
                    "stylua",
                    "prettier",
                },
                automatic_installation = true,
            })

            local null_ls = require("null-ls")

            null_ls.setup({
                sources = {
                    -- Lua
                    null_ls.builtins.formatting.stylua,
                    null_ls.builtins.formatting.prettier,
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
                    vim.cmd([[retab]])

                    if vim.fn.executable("ruff") == 1 then
                        local cmd_fix = string.format("ruff check --fix %q", filepath)
                        local cmd_format = string.format("ruff format %q", filepath)
                        local result = vim.fn.system(cmd_fix)
                        vim.fn.system(cmd_format)
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

            vim.api.nvim_create_autocmd("FileType", {
                pattern = "python",
                callback = function()
                    vim.opt_local.smartindent = true
                    vim.opt_local.autoindent = true
                    vim.opt_local.indentexpr = ""
                end,
            })

            -- Rust
            vim.api.nvim_create_autocmd("BufWritePre", {
                pattern = "*.rs",
                callback = function()
                    vim.lsp.buf.format({ async = false })
                end,
            })

            -- HTML, CSS, JS, JSON, TS
            vim.api.nvim_create_autocmd("BufWritePre", {
                pattern = { "*.html", "*.css", "*.js", "*.ts", "*.json" },
                callback = function()
                    vim.lsp.buf.format({ async = false })
                end,
            })
        end,
    },
}
