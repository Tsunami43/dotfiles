return {
    -- Плагины для автодополнения
    "hrsh7th/nvim-cmp",
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",     -- Источник автодополнения для LSP
        "hrsh7th/cmp-buffer",       -- Источник для слов из текущего буфера
        "hrsh7th/cmp-path",         -- Источник для файловой системы
        "saadparwaiz1/cmp_luasnip", -- Источник для сниппетов
        "L3MON4D3/LuaSnip",         -- Плагин для сниппетов
        "onsails/lspkind.nvim",
    },
    config = function()
        local cmp = require("cmp")
        local luasnip = require("luasnip")
        local lspkind = require("lspkind")

        cmp.setup({
            snippet = {
                expand = function(args)
                    luasnip.lsp_expand(args.body) -- Поддержка сниппетов
                end,
            },
            formatting = {
                format = lspkind.cmp_format({
                    mode = "symbol",
                    maxwidth = 50,
                    ellipsis_char = "...",
                    symbol_map = { Codeium = "" },
                }),
            },
            mapping = {
                ["<C-Space>"] = cmp.mapping.complete(),            -- Открыть меню автодополнения
                ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Подтвердить выбор
                ["<Down>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_next_item() -- Навигация по меню
                    else
                        fallback()             -- В случае, если меню не видно, выполнить стандартное действие
                    end
                end, { "i", "s" }),

                ["<Up>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_prev_item() -- Навигация по меню
                    else
                        fallback()             -- В случае, если меню не видно, выполнить стандартное действие
                    end
                end, { "i", "s" }),
            },
            sources = {
                { name = "nvim_lsp" }, -- Автодополнение от LSP
                { name = "luasnip" },  -- Сниппеты
                { name = "buffer" },   -- Слова из буфера
                { name = "path" },     -- Пути к файлам
                { name = "codeium" },
            },
        })
    end,
}
