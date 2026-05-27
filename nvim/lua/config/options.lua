-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Syntax formatting is bad (python)
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.py",
  callback = function()
    local filepath = vim.api.nvim_buf_get_name(0)
    vim.cmd([[retab]])

    if vim.fn.executable("ruff") == 1 then
      local cmd_fix = string.format("ruff check --fix %q", filepath)
      local cmd_format = string.format("ruff format %q", filepath)
      local result = vim.fn.system(cmd_fix)
      vim.fn.system(cmd_format)
      print(result)
    elseif vim.fn.executable("black") == 1 then
      local cmd = string.format("black %q", filepath)
      local result = vim.fn.system(cmd)
      print(result)
    else
      -- Fallback to LSP formatting
      vim.lsp.buf.format({ async = false })
      return
    end
    vim.cmd("checktime")
  end,
})
