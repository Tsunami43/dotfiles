-- basedpyright (community fork of pyright).
vim.lsp.config("basedpyright", {
  cmd = { "basedpyright-langserver", "--stdio" },
  filetypes = { "python" },
  root_markers = {
    "pyproject.toml",
    "setup.py",
    "setup.cfg",
    "requirements.txt",
    "Pipfile",
    "pyrightconfig.json",
    ".git",
  },
  settings = {
    basedpyright = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        -- Only diagnose open files; switch to "workspace" if you want
        -- whole-project squiggles (heavier on large repos).
        diagnosticMode = "openFilesOnly",
      },
    },
  },
})
vim.lsp.enable("basedpyright")

local python_indent_group = vim.api.nvim_create_augroup("python_indent", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = python_indent_group,
  pattern = "python",
  callback = function()
    vim.opt_local.expandtab = true
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.tabstop = 4
  end,
})

-- Formatters cannot parse a file with mixed indentation, so normalize tabs first.
vim.api.nvim_create_autocmd("BufWritePre", {
  group = python_indent_group,
  pattern = "*.py",
  command = "silent! retab",
})

-- Resolve a Python tool: prefer the nearest .venv/bin/<tool> walking up from
-- the file, fall back to whatever is on the system PATH. This lets `uv add ruff`
-- inside a project just work without launching nvim via `uv run`.
local function resolve_py_tool(tool, from_file)
  local venvs = vim.fs.find({ ".venv", "venv" }, {
    upward = true,
    path = vim.fs.dirname(from_file),
    type = "directory",
    limit = 1,
  })
  if venvs[1] then
    local p = venvs[1] .. "/bin/" .. tool
    if vim.fn.executable(p) == 1 then
      return p
    end
  end
  if vim.fn.executable(tool) == 1 then
    return tool
  end
  return nil
end

-- Format on save. Prefers ruff (fast, all-in-one), falls back to black.
-- If neither tool is found, the save still completes — we just don't format.
vim.api.nvim_create_autocmd("BufWritePost", {
  group = vim.api.nvim_create_augroup("python_format_on_save", { clear = true }),
  pattern = "*.py",
  callback = function()
    local file = vim.api.nvim_buf_get_name(0)
    local ruff = resolve_py_tool("ruff", file)
    if ruff then
      vim.fn.system({ ruff, "check", "--fix", file })
      vim.fn.system({ ruff, "format", file })
      vim.cmd("checktime") -- reload buffer if the formatter rewrote the file
      return
    end
    local black = resolve_py_tool("black", file)
    if black then
      vim.fn.system({ black, file })
      vim.cmd("checktime")
    end
  end,
})
