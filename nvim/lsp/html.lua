-- HTML language server (from vscode-langservers-extracted).
-- Install: npm install -g vscode-langservers-extracted
vim.lsp.config("html_ls", {
  cmd = { "vscode-html-language-server", "--stdio" },
  filetypes = { "html" },
  root_markers = { "package.json", ".git" },
  init_options = {
    provideFormatter = true,
    embeddedLanguages = { css = true, javascript = true },
    configurationSection = { "html", "css", "javascript" },
  },
})
vim.lsp.enable("html_ls")

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
  group = vim.api.nvim_create_augroup("html_format_on_save", { clear = true }),
  pattern = { "*.html", "*.htm" },
  callback = function()
    local file = vim.api.nvim_buf_get_name(0)
    local pr = resolve_node_tool("prettier", file)
    if pr then
      vim.fn.system({ pr, "--write", file })
      vim.cmd("checktime")
    end
  end,
})
