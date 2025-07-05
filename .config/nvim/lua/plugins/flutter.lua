return {
    "nvim-flutter/flutter-tools.nvim",
    lazy = false,
    dependencies = {
        "nvim-lua/plenary.nvim",
        "stevearc/dressing.nvim", -- optional
    },
    config = function()
        vim.api.nvim_create_autocmd("FileType", {
            pattern = "dart",
            callback = function()
                vim.bo.tabstop = 2
                vim.bo.shiftwidth = 2
                vim.bo.softtabstop = 2
                vim.bo.expandtab = true
                -- Replace
                local opts = { noremap = true, silent = true, buffer = true }
                vim.keymap.set("n", "R", "<cmd>FlutterRename<CR>", opts)
            end,
        })

        require("flutter-tools").setup({
            lsp = {
                settings = {
                    dart = {
                        renameFilesWithClasses = "always",
                        updateImportsOnRename = true,
                    },
                },
            },
        })
    end,
}
