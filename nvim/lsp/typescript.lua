-- typescript-language-server: handles .ts, .tsx, .js, .jsx (React works out of the box).
-- Install: npm install -g typescript typescript-language-server
vim.lsp.config("ts_ls", {
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
  root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
})
vim.lsp.enable("ts_ls")

-- Resolve a node tool: prefer the nearest node_modules/.bin/<tool> walking up
-- from the file, fall back to whatever is on the system PATH.
local function resolve_node_tool(tool, from_file)
  local nm = vim.fs.find("node_modules", {
    upward = true,
    path = vim.fs.dirname(from_file),
    type = "directory",
    limit = 1,
  })[1]
  if nm then
    local p = nm .. "/.bin/" .. tool
    if vim.fn.executable(p) == 1 then
      return p
    end
  end
  if vim.fn.executable(tool) == 1 then
    return tool
  end
  return nil
end

-- Format on save with prettier. No tool found -> save still completes.
vim.api.nvim_create_autocmd("BufWritePost", {
  group = vim.api.nvim_create_augroup("ts_format_on_save", { clear = true }),
  pattern = { "*.ts", "*.tsx", "*.js", "*.jsx", "*.mjs", "*.cjs" },
  callback = function()
    local file = vim.api.nvim_buf_get_name(0)
    local pr = resolve_node_tool("prettier", file)
    if pr then
      vim.fn.system({ pr, "--write", file })
      vim.cmd("checktime") -- reload buffer if the formatter rewrote the file
    end
  end,
})
