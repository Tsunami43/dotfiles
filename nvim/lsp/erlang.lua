-- ELP (Erlang Language Platform, AUR: `elp`). Works with modern OTP (28).
-- Started in LSP mode via `elp server`.
vim.lsp.config("elp", {
  cmd = { "elp", "server" },
  filetypes = { "erlang" },
  -- Attach only inside a real Erlang/rebar project, not in any git repo.
  root_markers = { "rebar.config", "erlang.mk" },
})
vim.lsp.enable("elp")
