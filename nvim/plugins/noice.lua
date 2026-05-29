-- noice.nvim: replaces the UI for cmdline, messages and popupmenu.
-- nui.nvim is required; nvim-notify is the notification backend.
vim.pack.add({
  { src = "https://github.com/MunifTanjim/nui.nvim" },
  { src = "https://github.com/rcarriga/nvim-notify" },
  { src = "https://github.com/folke/noice.nvim" },
})

require("noice").setup({
  presets = {
    command_palette = true, -- cmdline + completion shown together, centered near the top
  },
})
