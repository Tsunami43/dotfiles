vim.pack.add({
    'https://github.com/nvim-tree/nvim-web-devicons',
    'https://github.com/nvim-lualine/lualine.nvim'
})

local c = require("cendre.palette").get("hard")

-- The mode block is the bar's one filled surface — everything else is ink on
-- the same dark ground, so the bar reads as a single band and the mode is the
-- only thing in it that changes colour.
local block = function(bg) return { bg = bg, fg = c.bg0, gui = "bold" } end

local theme = {
  normal = {
    a = block(c.ember),
    b = { bg = c.bg_deep, fg = c.fg_dim },
    c = { bg = c.bg_deep, fg = c.comment },
  },
  insert = { a = block(c.sap) },
  visual = { a = block(c.brass) },
  replace = { a = block(c.cinder) },
  command = { a = block(c.warn) },
  inactive = {
    a = { bg = c.bg_deep, fg = c.comment },
    b = { bg = c.bg_deep, fg = c.gutter },
    c = { bg = c.bg_deep, fg = c.gutter },
  },
}

require('lualine').setup({
  options = {
    theme = theme,
    -- No arrows, no chevrons: the sections are separated by the space between
    -- them, and a filled separator would give each one a border it doesn't need.
    section_separators = "",
    component_separators = "",
    globalstatus = true, -- matches options.lua's laststatus = 3
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = {
      { "filename", path = 0, symbols = { modified = " ●", readonly = " ", newfile = "" } },
    },
    lualine_c = { { "branch", icon = "" } },
    -- Filetype and position live in x rather than y/z: y and z inherit the
    -- filled styling of b and a, and a second block on the right would answer
    -- the mode block instead of staying quiet.
    lualine_x = {
      { "filetype", colored = false, icon_only = false },
      "location",
    },
    lualine_y = {},
    lualine_z = {},
  },
})
