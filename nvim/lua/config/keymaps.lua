-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Disable ctrl+b
vim.keymap.set({ "n", "v", "i" }, "<C-b>", "<Nop>", { noremap = true, silent = true })

-- <leader>fw: live grep across the project (type to search)
vim.keymap.set("n", "<leader>fw", function()
  local ok, snacks = pcall(require, "snacks")
  if ok and snacks.picker then
    snacks.picker.grep()
    return
  end
  local ok_tb, tb = pcall(require, "telescope.builtin")
  if ok_tb then
    tb.live_grep()
    return
  end
  vim.ui.input({ prompt = "Grep: " }, function(q)
    if q and q ~= "" then
      vim.cmd("silent grep! " .. vim.fn.shellescape(q))
      vim.cmd("copen")
    end
  end)
end, { desc = "Live grep", silent = true })
