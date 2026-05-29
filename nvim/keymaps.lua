local map = vim.keymap.set

-- General keymaps (plugin-specific ones live in their plugins/*.lua files).

-- Disable Ctrl+b (carried over from the old config).
map({ "n", "v", "i" }, "<C-b>", "<Nop>", { noremap = true, silent = true })

-- Reload the whole config (re-run init.lua). dofile() has no module cache,
-- so every options/keymaps/plugins file is re-sourced fresh.
map("n", "<leader>r", function()
  dofile(vim.fn.stdpath("config") .. "/init.lua")
  vim.notify("Config reloaded", vim.log.levels.INFO)
end, { desc = "Reload config" })
