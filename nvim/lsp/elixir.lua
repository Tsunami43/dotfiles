-- elixir-ls (Arch: `pacman -S elixir-ls`; ships the `elixir-ls` launcher on PATH).
vim.lsp.config("elixirls", {
  cmd = { "elixir-ls" },
  filetypes = { "elixir", "eelixir", "heex", "surface" },
  -- Only attach inside a real Mix project; no `.git` fallback, otherwise the
  -- launcher would build and run elixir-ls in any git repo (e.g. this config).
  root_markers = { "mix.exs" },
})
vim.lsp.enable("elixirls")

-- Format on save via Elixir's built-in formatter (`mix format`, honours .formatter.exs).
-- If mix isn't available, the save still completes.
vim.api.nvim_create_autocmd("BufWritePost", {
  group = vim.api.nvim_create_augroup("elixir_format_on_save", { clear = true }),
  pattern = { "*.ex", "*.exs", "*.heex", "*.eex" },
  callback = function()
    local file = vim.api.nvim_buf_get_name(0)
    if vim.fn.executable("mix") == 1 then
      vim.fn.system({ "mix", "format", file })
      vim.cmd("checktime")
    end
  end,
})
