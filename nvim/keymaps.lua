local map = vim.keymap.set

-- General keymaps (plugin-specific ones live in their plugins/*.lua files).

-- Disable Ctrl+b (carried over from the old config).
map({ "n", "v", "i" }, "<C-b>", "<Nop>", { noremap = true, silent = true })
