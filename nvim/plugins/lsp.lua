-- LSP plumbing: completion engine + on-attach behavior.
-- Per-server configs live in lsp/<name>.lua and are enabled from init.lua.

-- blink.cmp: completion popup as you type, fuzzy matching, LSP/path/snippet/buffer sources.
-- Pinned to the v1 line for stability. The Rust fuzzy library is auto-downloaded
-- on first start; if that fails, blink falls back to a pure-Lua matcher.
vim.pack.add({
  { src = "https://github.com/Saghen/blink.cmp", version = vim.version.range("1") },
})

require("blink.cmp").setup({
  keymap = {
    preset = "default",
    ["<C-j>"] = { "select_next", "fallback" },
    ["<C-k>"] = { "select_prev", "fallback" },
    ["<CR>"] = { "accept", "fallback" },
  },
})

-- Buffer-local LSP setup on attach. Completion is owned by blink.cmp above,
-- so we don't register the native vim.lsp.completion here.
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("user_lsp_attach", { clear = true }),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    local buf = ev.data.buf

    vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = buf, desc = "Go to definition" })
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buffer = buf, desc = "Go to declaration" })

    -- Inline type/parameter hints, if the server provides them.
    if client and client:supports_method("textDocument/inlayHint") then
      vim.lsp.inlay_hint.enable(true, { bufnr = buf })
    end
  end,
})
