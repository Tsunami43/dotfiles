-- fzf-lua: fuzzy finder backed by the `fzf` binary (Telescope replacement).
-- Icons come from nvim-web-devicons (added by plugins/devicons.lua).
vim.pack.add({
  { src = "https://github.com/ibhagwan/fzf-lua" },
})

local fzf = require("fzf-lua")
fzf.setup({})

local map = vim.keymap.set
map("n", "<leader><space>", fzf.files, { desc = "Find files" })
map("n", "<leader>ff", fzf.files, { desc = "Find files" })
map("n", "<leader>fw", fzf.live_grep, { desc = "Live grep" })
map("n", "<leader>fb", fzf.buffers, { desc = "Buffers" })
map("n", "<leader>fr", fzf.oldfiles, { desc = "Recent files" })
map("n", "<leader>fh", fzf.help_tags, { desc = "Help tags" })
map("n", "<leader>fd", fzf.diagnostics_document, { desc = "Diagnostics" })
