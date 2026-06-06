-- rust-analyzer (installed via rustup component or cargo install).
vim.lsp.config("rust_analyzer", {
	cmd = { "rust-analyzer" },
	filetypes = { "rust" },
	root_markers = { "Cargo.toml", "rust-project.json", ".git" },
})
vim.lsp.enable("rust_analyzer")

-- Format on save via rust-analyzer (uses rustfmt under the hood).
vim.api.nvim_create_autocmd("BufWritePre", {
	group = vim.api.nvim_create_augroup("rust_format_on_save", { clear = true }),
	pattern = "*.rs",
	callback = function(args)
		vim.lsp.buf.format({ bufnr = args.buf, timeout_ms = 2000 })
	end,
})
