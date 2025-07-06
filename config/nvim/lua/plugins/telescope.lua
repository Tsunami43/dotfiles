return {

    "nvim-telescope/telescope.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope-fzy-native.nvim",
    },
    config = function()
        local telescope = require("telescope")
        -- local builtin = require("telescope.builtin")

        -- Загружаем расширение fzy-native для улучшенной фильтрации
        telescope.load_extension("fzy_native")
        telescope.load_extension("flutter")
        -- Настройки Telescope
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
        -- Hotkeys for Git
        -- vim.keymap.set("n", "<leader>gs", ":Telescope git_status<CR>", { noremap = true, silent = true, desc = "Git Status" })
        -- vim.keymap.set("n", "<leader>gc", ":Telescope git_commits<CR>", { noremap = true, silent = true, desc = "Git Commits" })
        -- Switch Git Branch
        -- vim.keymap.set("n", "<leader>gb", function()
        --   -- Open Telescope for Git Branches
        --   builtin.git_branches({
        --     attach_mappings = function(prompt_bufnr, map)
        --       -- Press enter to switch to the selected branch
        --       map('i', '<CR>', function()
        --         local selection = require('telescope.actions.state').get_selected_entry()
        --         require('telescope.actions').close(prompt_bufnr)
        --         vim.cmd('git checkout ' .. selection.value)
        --       end)
        --       return true
        --     end
        --   })
        -- end, { noremap = true, silent = true, desc = "Git Branches" })
    end,
}
