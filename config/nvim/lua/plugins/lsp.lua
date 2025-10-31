return {
	"neovim/nvim-lspconfig",
	config = function()
		local lspconfig = require("lspconfig")
		-- Configure diagnostics
		vim.diagnostic.config({
			virtual_text = false, -- Show diagnostics as virtual text
			signs = true, -- Show signs in sign column
			underline = true, -- Underline problematic text
			update_in_insert = true, -- update diagnostics in insert mode
			severity_sort = true, -- Sort by severity
			float = {
				focusable = false,
				style = "minimal",
				border = "rounded",
				source = "always",
				header = "",
				prefix = "",
			},
		})
		-- LSP keymaps
		local on_attach = function(client, bufnr)
			local opts = { noremap = true, buffer = bufnr, silent = true }
			vim.keymap.set("n", "R", vim.lsp.buf.rename, opts) -- Rename symbol
			vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts) -- Code actions
			-- Diagnostic keymaps
			vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts) -- Show diagnostic popup
			vim.keymap.set("n", "<leader>dN", vim.diagnostic.goto_prev, opts) -- Previous diagnostic
			vim.keymap.set("n", "<leader>dn", vim.diagnostic.goto_next, opts) -- Next diagnostic
			-- Copy diagnostic to clipboard
			vim.keymap.set("n", "<leader>dy", function()
				local diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 })
				if #diagnostics > 0 then
					local message = diagnostics[1].message
					vim.fn.setreg("+", message) -- Copy to system clipboard
					print("Diagnostic copied: " .. message)
				else
					print("No diagnostic on current line")
				end
			end, opts)
		end

		-- Setup language servers (install manually)
		lspconfig.lua_ls.setup({ on_attach = on_attach }) -- brew install lua-language-server
		lspconfig.pyright.setup({ on_attach = on_attach }) -- npm install -g typescript-language-server typescript
		lspconfig.ts_ls.setup({ on_attach = on_attach }) -- npm install -g pyright
		lspconfig.gopls.setup({ on_attach = on_attach }) -- go install golang.org/x/tools/gopls@latest
		lspconfig.rust_analyzer.setup({ on_attach = on_attach }) -- rustup component add rust-analyzer

		-- Elixir LSP
		lspconfig.elixirls.setup({
			cmd = { vim.fn.expand("~./development/elixir-ls/release/language_server.sh") }, -- https://github.com/elixir-lsp/elixir-ls.git
			on_attach = on_attach,
			root_dir = lspconfig.util.root_pattern("mix.exs", ".git"),
			settings = {
				elixirLS = {
					dialyzerEnabled = true,
					fetchDeps = false,
				},
			},
		})

		-- Python formatting
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

		-- Lua formatting (requires: cargo install stylua)
		vim.api.nvim_create_autocmd("BufWritePost", {
			pattern = "*.lua",
			callback = function()
				local filepath = vim.api.nvim_buf_get_name(0)
				if vim.fn.executable("stylua") == 1 then
					local cmd = string.format("stylua %q", filepath)
					local result = vim.fn.system(cmd)
					print("Formatted with stylua")
				else
					-- Fallback to LSP formatting
					vim.lsp.buf.format({ async = false })
					print("Formatted with LSP")
				end
				vim.cmd("checktime")
			end,
		})

		-- Go formatting on save
		vim.api.nvim_create_autocmd("BufWritePost", {
			pattern = "*.go",
			callback = function()
				local filepath = vim.api.nvim_buf_get_name(0)

				if vim.fn.executable("gofmt") == 1 then
					-- Format file with gofmt
					local cmd = string.format("gofmt -w %q", filepath)
					local result = vim.fn.system(cmd)
					print("Formatted with gofmt")
				elseif vim.fn.executable("goimports") == 1 then
					-- Alternative: goimports adds/removes imports
					local cmd = string.format("goimports -w %q", filepath)
					local result = vim.fn.system(cmd)
					print("Formatted with goimports")
				else
					-- Fallback: use LSP gopls
					vim.lsp.buf.format({ async = false })
					print("Formatted with gopls LSP")
				end

				-- Reload buffer
				vim.cmd("checktime")
			end,
		})

		-- Rust formatting on save
		vim.api.nvim_create_autocmd("BufWritePost", {
			pattern = "*.rs",
			callback = function()
				local filepath = vim.api.nvim_buf_get_name(0)

				if vim.fn.executable("rustfmt") == 1 then
					-- Format file with rustfmt
					local cmd = string.format("rustfmt %q", filepath)
					vim.fn.system(cmd)
					print("Formatted with rustfmt")
				else
					-- Fallback: use LSP rust-analyzer
					vim.lsp.buf.format({ async = false })
					print("Formatted with rust-analyzer LSP")
				end

				-- Reload buffer so Neovim picks up changes
				vim.cmd("checktime")
			end,
		})

		-- Formatting JavaScript typescript html css -- npm install -g prettier
		vim.api.nvim_create_autocmd("BufWritePost", {
			pattern = { "*.js", "*.ts", "*.jsx", "*.tsx", "*.html", "*.css", "*.json" },
			callback = function()
				local filepath = vim.api.nvim_buf_get_name(0)
				if vim.fn.executable("prettier") == 1 then
					local cmd = string.format("prettier --write %q", filepath)
					vim.fn.system(cmd)
					print("Formatted with Prettier")
				else
					-- fallback: LSP formatting
					vim.lsp.buf.format({ async = false })
					print("Formatted with LSP")
				end
				vim.cmd("checktime")
			end,
		})

		-- Elixir
		vim.api.nvim_create_autocmd("BufWritePost", {
			pattern = { "*.ex", "*.exs" },
			callback = function()
				local filepath = vim.api.nvim_buf_get_name(0)
				vim.fn.system(string.format("mix format %q", filepath))
				print("Formatted with mix format")
				vim.cmd("checktime")
			end,
		})
	end,
}
