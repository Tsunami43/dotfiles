-- Uses plenary.nvim (already pulled in by plugins/telescope.lua) for the floating window.
vim.pack.add({
  { src = "https://github.com/kdheepak/lazygit.nvim" },
})

vim.keymap.set("n", "<leader>g", "<cmd>LazyGit<cr>", { desc = "LazyGit" })
