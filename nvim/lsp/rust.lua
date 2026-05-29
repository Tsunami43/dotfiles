-- rust-analyzer (installed via rustup component or cargo install).
vim.lsp.config("rust_analyzer", {
  cmd = { "rust-analyzer" },
  filetypes = { "rust" },
  root_markers = { "Cargo.toml", "rust-project.json", ".git" },
})
vim.lsp.enable("rust_analyzer")

-- Format on save with rustfmt. No tool found -> save still completes.
vim.api.nvim_create_autocmd("BufWritePost", {
  group = vim.api.nvim_create_augroup("rust_format_on_save", { clear = true }),
  pattern = "*.rs",
  callback = function()
    if vim.fn.executable("rustfmt") == 1 then
      vim.fn.system({ "rustfmt", vim.api.nvim_buf_get_name(0) })
      vim.cmd("checktime") -- reload buffer if the formatter rewrote the file
    end
  end,
})
