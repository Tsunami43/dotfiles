-- Open buffers as a row of names across the top.
--
-- Named tabline.lua rather than bufferline.lua so it sorts after
-- colorscheme.lua: init.lua sources this directory in alphabetical order, and
-- the palette below lives inside the cendre package, which only reaches the
-- runtimepath once colorscheme.lua has run.
vim.pack.add({ "https://github.com/akinsho/bufferline.nvim" })

local c = require("cendre.palette").get("hard")

local bufferline = require("bufferline")

-- The row sits one layer below the editor and the focused buffer rises to the
-- editor's own ground, so the active tab reads as the continuation of the
-- buffer under it. The ember rule is the only accent the row is allowed.
local sel = { fg = c.fg, bg = c.bg0, sp = c.ember, underline = true }
local off = { fg = c.comment, bg = c.bg_deep }

bufferline.setup({
  options = {
    mode = "buffers",
    style_preset = bufferline.style_preset.no_italic,
    themable = true,
    numbers = "none",
    indicator = { style = "underline" },
    -- Names only. Filetype icons would double the row's weight to repeat what
    -- the extension already says, and diagnostics are reported at the line
    -- they happen on, not up here.
    show_buffer_icons = false,
    show_buffer_close_icons = false,
    show_close_icon = false,
    diagnostics = false,
    separator_style = { "", "" },
    always_show_bufferline = true,
    modified_icon = "●",
    max_name_length = 24,
    tab_size = 14,
  },
  highlights = {
    fill = { bg = c.bg_deep },
    background = off,
    buffer_visible = { fg = c.fg_dim, bg = c.bg_deep },
    buffer_selected = vim.tbl_extend("force", sel, { bold = false, italic = false }),
    indicator_selected = { fg = c.ember, bg = c.bg0, sp = c.ember },
    indicator_visible = { fg = c.bg_deep, bg = c.bg_deep },
    separator = { fg = c.bg_deep, bg = c.bg_deep },
    separator_visible = { fg = c.bg_deep, bg = c.bg_deep },
    separator_selected = { fg = c.bg0, bg = c.bg0 },
    modified = { fg = c.warn, bg = c.bg_deep },
    modified_visible = { fg = c.warn, bg = c.bg_deep },
    modified_selected = vim.tbl_extend("force", sel, { fg = c.warn }),
    duplicate = { fg = c.gutter, bg = c.bg_deep, italic = false },
    duplicate_visible = { fg = c.comment, bg = c.bg_deep, italic = false },
    duplicate_selected = vim.tbl_extend("force", sel, { fg = c.fg_dim, italic = false }),
    offset_separator = { fg = c.bg3, bg = c.bg_deep },
  },
})

local map = vim.keymap.set
map("n", "]b", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })
map("n", "[b", "<cmd>BufferLineCyclePrev<cr>", { desc = "Previous buffer" })
-- The same two moves under the thumb. <Tab> is <C-i> at the byte level, so this
-- costs the jumplist's forward jump; <C-o> back still works, and the jump
-- forward is reachable through the jumplist window.
map("n", "<Tab>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })
map("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Previous buffer" })
map("n", "<leader>bp", "<cmd>BufferLinePick<cr>", { desc = "Pick buffer" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Close buffer" })
