-- Leader key is space
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- Move to beginning/end of line
map("n", "<S-h>", "0", opts)
map("n", "<S-l>", "$", opts)

-- Remap the 'u' key to call the function
function MyCustomUndoFunction()
    vim.cmd("undo")
    vim.cmd("nohlsearch")
end

map("n", "u", ":lua MyCustomUndoFunction()<CR>", { noremap = true, silent = true })

-- Remap the 'x' key to call the function
vim.keymap.set("n", "x", [["_x]])
-- leader d delete wont remember as yanked/clipboard when delete pasting
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])
map("n", "d", '"_d', opts)
map("n", "dd", '"_dd', opts)
map("v", "d", '"_d', opts)

-- Paste empty line
map("n", "<CR>", "o<Esc>", opts)

-- New splits
map("n", "<C-w><C-h>", ":vsplit<CR>", opts)
map("n", "<C-w><C-j>", ":split<CR>", opts)
map("n", "<C-w><C-k>", ":split<CR>", opts)
map("n", "<C-w><C-l>", ":vsplit<CR>", opts)

-- Открытие/фокусировка neo-tree
map("n", "<leader>e", ":Neotree toggle<CR>", opts) -- Открыть или закрыть neo-tree

-- Move text
map("v", "<C-L>", ":'<,'>normal! >><CR> V'<,'>", opts)
map("v", "<C-H>", ":'<,'>normal! <<<CR> V'<,'>", opts)
map("v", "<C-K>", ":'<,'>move -2<CR>gv", opts)
map("v", "<C-J>", ":move '>+1<cr>gv=gv", opts)

-- Move to window
map("n", "<C-h>", "<C-w>h", opts)
map("n", "<C-j>", "<C-w>j", opts)
map("n", "<C-k>", "<C-w>k", opts)
map("n", "<C-l>", "<C-w>l", opts)

-- Close buffer or exit nvim
map("n", "<C-q>", ":q<CR>", opts)
map("n", "<C-c>", ":qa!<CR>", opts) -- Close all

-- Save file
map("n", "<C-s>", ":w<CR>", opts)

-- Move to down line
map("n", "<S-j>", "8j", opts)
-- Move to up line
map("n", "<S-k>", "8k", opts)

-- Delete lines in Visual mode
map("o", "H", "^", opts)
map("o", "L", "g_", opts)

-- Search current word where cursor
function search_current_word()
    if vim.v.hlsearch == 1 then
        vim.cmd("nohlsearch") -- Off highllight
    else
        local word = vim.fn.expand("<cword>")
        vim.cmd('execute "normal! /' .. word .. '\\<CR>"')
    end
end

map("n", "<leader>v", ":lua search_current_word()<CR>", opts)

-- Select lines in Visual mode
map("v", "<S-j>", "10j", opts)
map("v", "<S-k>", "10k", opts)
map("v", "<S-h>", "^", opts)
map("v", "<S-l>", "g_", opts)

-- Function to replace input text
_G.replace_selected_or_prompt = function()
    local search_pattern = vim.fn.input("Replace target: ")
    if search_pattern == "" then
        print("Error: Empty search pattern!")
        return
    end

    local current_text = vim.fn.getline(1, "$")
    local found = false
    for _, line in ipairs(current_text) do
        if string.find(line, search_pattern) then
            found = true
            break
        end
    end

    if not found then
        print("Error replace: '" .. search_pattern .. "' not found!")
        return
    end

    local replacement = vim.fn.input("New text: ")

    local command = string.format(
        "%%s/%s/%s/g",
        vim.fn.escape(search_pattern, "/\\."),
        vim.fn.escape(replacement, "/\\")
    )

    local success, err = pcall(function()
        vim.cmd(command)
    end)

    if not success then
        print("Error replace: " .. err)
    end

    vim.cmd("normal! n")
end

-- Command to replace input text
map("n", "R", "<cmd>lua _G.replace_selected_or_prompt()<CR>", opts)

-- Paste # type: ignore
_G.insert_type_ignore = function()
    local line = vim.api.nvim_get_current_line()
    local new_line = line .. " # type: ignore"
    vim.api.nvim_set_current_line(new_line)
end
map("n", '"', ":lua insert_type_ignore()<CR>", opts)

-- Delete
map("n", "<Space>", "", opts)
map("n", "<C-f>", "", opts)
map("n", "c", "", opts)
