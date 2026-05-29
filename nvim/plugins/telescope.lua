-- vim.pack has no build hooks, so compile telescope-fzf-native on install/update.
vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    local d = ev.data
    if d.spec.name == "telescope-fzf-native.nvim" and (d.kind == "install" or d.kind == "update") then
      vim.system({ "make" }, { cwd = d.path }):wait()
    end
  end,
})

vim.pack.add({
  { src = "https://github.com/nvim-lua/plenary.nvim" },
  { src = "https://github.com/nvim-tree/nvim-web-devicons" },
  { src = "https://github.com/nvim-telescope/telescope.nvim" },
  { src = "https://github.com/nvim-telescope/telescope-fzf-native.nvim" },
})

local telescope = require("telescope")
telescope.setup({
  defaults = {
    layout_strategy = "horizontal",
    layout_config = { prompt_position = "top" },
    sorting_strategy = "ascending",
  },
})
-- Native fzf sorter; ignored gracefully if the build has not run yet.
pcall(telescope.load_extension, "fzf")

local builtin = require("telescope.builtin")
local map = vim.keymap.set
map("n", "<leader><space>", builtin.find_files, { desc = "Find files" })
map("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
map("n", "<leader>fw", builtin.live_grep, { desc = "Live grep" })
map("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
map("n", "<leader>fr", builtin.oldfiles, { desc = "Recent files" })
map("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
map("n", "<leader>fd", builtin.diagnostics, { desc = "Diagnostics" })
