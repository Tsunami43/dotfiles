-- nvim-treesitter (main branch): semantic syntax highlighting.
-- The regex-based Vim syntax engine has very few groups, so highlighting looks
-- flat; treesitter exposes many more (variables, fields, params, types, ...)
-- which the colorscheme can then paint distinctly.
--
-- The `main` branch is the modern API for Neovim 0.12+. It does NOT auto-enable
-- highlighting: parsers are installed with .install() and highlighting is turned
-- on per-buffer via vim.treesitter.start() on FileType.
-- vim.pack.add({
--   { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
-- })
--
-- -- Parsers to install/compile (async on first run). Add languages as needed.
-- require("nvim-treesitter").install({
--   "lua", "vim", "vimdoc", "query", "bash",
--   "go", "rust", "python",
--   "typescript", "javascript", "tsx",
--   "html", "css", "json", "yaml", "toml",
--   "markdown", "markdown_inline",
--   "elixir", "eex", "heex",
--   "erlang",
-- })

-- Enable treesitter highlighting for any buffer that has a parser available.
-- pcall guards files whose parser isn't installed (or hasn't compiled yet).
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("user_treesitter_start", { clear = true }),
	callback = function(args)
		pcall(vim.treesitter.start, args.buf)
	end,
})
