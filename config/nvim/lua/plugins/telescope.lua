return {
    "nvim-telescope/telescope.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope-fzy-native.nvim",
    },
    config = function()
        local telescope = require("telescope")
        -- local builtin = require("telescope.builtin")

        telescope.load_extension("fzy_native")
        telescope.load_extension("flutter")
        telescope.setup({
            extensions = {
                fzy_native = {
                    override_generic_sorter = false,
                    override_file_sorter = true,
                },
            },
        })

        -- Hotkeys
        vim.keymap.set(
            "n",
            "<leader>b",
            ":Telescope find_files<CR><ESC>",
            { noremap = true, silent = true, desc = "Search files" }
        )
        vim.keymap.set(
            "n",
            "<leader>f",
            ":Telescope live_grep<CR>",
            { noremap = true, silent = true, desc = "Search text" }
        )

        vim.keymap.set(
            "n",
            "<leader>gd",
            ":Telescope lsp_definitions<CR><ESC>",
            { noremap = true, silent = true, desc = "Go to definition" }
        )

        vim.keymap.set(
            "n",
            "<leader>gt",
            ":Telescope diagnostics<CR><ESC>",
            { noremap = true, silent = true, desc = "Diagnostics" }
        )
    end,
}
