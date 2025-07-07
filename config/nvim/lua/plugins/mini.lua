return {
    "echasnovski/mini.nvim",
    config = function()
        require("mini.indentscope").setup({})
        require("mini.icons").setup({})
        require("mini.animate").setup({
            cursor = {
                enable = false,
            },
        })
    end,
}
