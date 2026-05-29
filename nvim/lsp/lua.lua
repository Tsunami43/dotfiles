-- lua_ls (lua-language-server). Tuned for editing Neovim config:
-- knows the `vim` global and the nvim runtime API.
vim.lsp.config("lua_ls", {
	cmd = { "lua-language-server" },
	filetypes = { "lua" },
	root_markers = { ".luarc.json", ".luarc.jsonc", ".stylua.toml", ".git", "init.lua" },
	settings = {
		Lua = {
			runtime = { version = "LuaJIT" },
			diagnostics = { globals = { "vim" } },
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
				checkThirdParty = false,
			},
			telemetry = { enable = false },
		},
	},
})

vim.lsp.enable("lua_ls")

-- Format on save with stylua, if installed. Otherwise the save still completes
-- — we just don't format.
vim.api.nvim_create_autocmd("BufWritePost", {
	group = vim.api.nvim_create_augroup("lua_format_on_save", { clear = true }),
	pattern = "*.lua",
	callback = function()
		if vim.fn.executable("stylua") == 1 then
			vim.fn.system({ "stylua", vim.api.nvim_buf_get_name(0) })
			vim.cmd("checktime")
		end
	end,
})
