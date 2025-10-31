return {
	"NickvanDyke/opencode.nvim",
	dependencies = {
		-- Recommended for better prompt input, and required to use `opencode.nvim`'s embedded terminal — otherwise optional
		{ "folke/snacks.nvim", opts = { input = { enabled = true } } },
	},

	config = function()
		vim.g.opencode_opts = {
			-- Your configuration, if any — see `lua/opencode/config.lua`
		}

		-- Required for `opts.auto_reload`
		vim.opt.autoread = true -- Enable autoread to reflect external edits to files (opencode prompts, config, etc.)

		-- Recommended keymaps
		vim.keymap.set("n", "<leader>at", function()
			require("opencode").toggle()
		end, { desc = "Toggle" })
		vim.keymap.set("n", "<leader>aA", function()
			require("opencode").ask()
		end, { desc = "Ask" })
		vim.keymap.set("n", "<leader>aa", function()
			require("opencode").ask("@cursor: ")
		end, { desc = "Ask about this" })
		vim.keymap.set("v", "<leader>aa", function()
			require("opencode").ask("@selection: ")
		end, { desc = "Ask about selection" })
		vim.keymap.set("n", "<leader>a+", function()
			require("opencode").append_prompt("@buffer")
		end, { desc = "Add buffer to prompt" })
		vim.keymap.set("v", "<leader>a+", function()
			require("opencode").append_prompt("@selection")
		end, { desc = "Add selection to prompt" })
		vim.keymap.set("n", "<leader>on", function()
			require("opencode").command("session_new")
		end, { desc = "New session" })
		vim.keymap.set("n", "<leader>ay", function()
			require("opencode").command("messages_copy")
		end, { desc = "Copy last response" })
		vim.keymap.set("n", "<C-S-u>", function()
			require("opencode").command("messages_half_page_up")
		end, { desc = "Messages half page up" })
		vim.keymap.set("n", "<C-S-d>", function()
			require("opencode").command("messages_half_page_down")
		end, { desc = "Messages half page down" })
		vim.keymap.set({ "n", "v" }, "<leader>as", function()
			require("opencode").select()
		end, { desc = "Select prompt" })

		-- Example: keymap for custom prompt
		vim.keymap.set("n", "<leader>ae", function()
			require("opencode").prompt("Explain @cursor and its context")
		end, { desc = "Explain this code" })
	end,
}
