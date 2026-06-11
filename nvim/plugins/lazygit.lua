-- plenary.nvim provides the floating window helpers lazygit.nvim needs.
vim.pack.add({
  { src = "https://github.com/nvim-lua/plenary.nvim" },
  { src = "https://github.com/kdheepak/lazygit.nvim" },
})

vim.keymap.set("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "LazyGit" })

-- Called by lazygit via `nvim --remote-expr` (see os.edit in
-- ~/.config/lazygit/config.yml): closes the lazygit float, opens the
-- file in the previous window and asks lazygit to quit. Everything runs
-- inside the parent nvim, so it does not depend on the lazygit terminal
-- process surviving (the plugin kills it together with its children).
function _G.LazyGitEditFromFloat(path, line)
  local chan = vim.bo.channel
  vim.cmd.stopinsert()
  pcall(vim.api.nvim_win_close, 0, true)
  vim.cmd.edit(vim.fn.fnameescape(path))
  if line then
    pcall(vim.api.nvim_win_set_cursor, 0, { line, 0 })
  end
  -- quit lazygit cleanly so the plugin's on_exit callback resets its state
  if chan and chan > 0 then
    vim.fn.chansend(chan, "q")
  end
  return ""
end
