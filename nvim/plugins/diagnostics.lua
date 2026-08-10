-- Inline diagnostics: a coloured square carries the severity, the message
-- trails it at comment weight. Splitting the two means the line of code is
-- still the brightest thing on its row — a full-colour sentence hanging off
-- the end of every statement competes with the code for the same eye.

local severity = vim.diagnostic.severity

-- The square borrows the severity's own colour; the text does not.
local marker_hl = {
  [severity.ERROR] = "DiagnosticError",
  [severity.WARN] = "DiagnosticWarn",
  [severity.INFO] = "DiagnosticInfo",
  [severity.HINT] = "DiagnosticHint",
}

vim.diagnostic.config({
  virtual_text = {
    spacing = 2,
    -- prefix() may return its own highlight group, which is the one seam where
    -- a virtual-text chunk can carry a colour the message body doesn't.
    prefix = function(diagnostic)
      return "■ ", marker_hl[diagnostic.severity] or "DiagnosticHint"
    end,
    -- Only the message, without the "go: " server prefix some LSPs prepend.
    format = function(diagnostic)
      return diagnostic.message:gsub("%s+", " ")
    end,
  },
  -- The sign column belongs to gitsigns. Diagnostics already announce
  -- themselves at the end of the line and underlined beneath the span.
  signs = false,
  underline = true,
  severity_sort = true,
  float = {
    border = "rounded",
    source = "if_many",
    header = "",
  },
})

-- Message text sits at comment weight in every severity, italic to separate it
-- from the code it annotates. Re-applied on :colorscheme, which clears these.
local function quiet_virtual_text()
  local c = require("cendre.palette").get("hard")
  for _, name in ipairs({ "Error", "Warn", "Info", "Hint", "Ok" }) do
    vim.api.nvim_set_hl(0, "DiagnosticVirtualText" .. name, {
      fg = c.comment,
      bg = "NONE",
      italic = true,
    })
  end
end

vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("user_diagnostic_hl", { clear = true }),
  callback = quiet_virtual_text,
})

quiet_virtual_text()
