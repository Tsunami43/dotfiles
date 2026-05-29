-- gopls (install: `go install golang.org/x/tools/gopls@latest`; ensure ~/go/bin is in PATH).
vim.lsp.config("gopls", {
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  root_markers = { "go.mod", "go.work", ".git" },
})
vim.lsp.enable("gopls")

-- Format on save: prefer goimports (also organizes imports), fall back to gofmt.
-- If neither is available, the save still completes.
vim.api.nvim_create_autocmd("BufWritePost", {
  group = vim.api.nvim_create_augroup("go_format_on_save", { clear = true }),
  pattern = "*.go",
  callback = function()
    local file = vim.api.nvim_buf_get_name(0)
    if vim.fn.executable("goimports") == 1 then
      vim.fn.system({ "goimports", "-w", file })
      vim.cmd("checktime")
    elseif vim.fn.executable("gofmt") == 1 then
      vim.fn.system({ "gofmt", "-w", file })
      vim.cmd("checktime")
    end
  end,
})
