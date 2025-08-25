# Maven Neovim Configuration

A modern, IDE-like Neovim configuration focused on Python, Lua, JavaScript/TypeScript development with beautiful UI and powerful features.

## Features

- 🚀 **Fast startup** with lazy loading
- 🎨 **Beautiful UI** with Catppuccin theme
- 📁 **File tree** with Neo-tree (floating window)
- 🔍 **Fuzzy finder** with Telescope
- 🎯 **LSP support** with autocompletion and diagnostics
- ✨ **Auto-formatting** for Python, Lua, and other languages
- 📊 **Status line** with file info, git status, and LSP info
- 🎪 **Dashboard** with quick actions
- 💡 **Signature help** for function parameters
- 🌿 **Git integration** with Telescope and GitSigns visual markers

## Requirements

### Essential
- **Neovim** >= 0.9.0
- **Git** (for plugin management)
- **Node.js** and **npm** (for LSP servers)
- **make** (for compiling telescope-fzf-native)


### Language Servers (install manually)
```bash
# Lua Language Server
brew install lua-language-server

# Python Language Server
npm install -g pyright

# TypeScript/JavaScript Language Server  
npm install -g typescript-language-server typescript
```

### Formatters (optional but recommended)

#### Python
```bash
# Ruff (recommended - fastest)
pip install ruff

# OR Black (alternative)
pip install black
```

#### Lua
```bash
# StyLua (recommended)
cargo install stylua
# OR via Homebrew
brew install stylua
```

#### JavaScript/TypeScript
```bash
# Prettier
npm install -g prettier
```

### Fonts
- **Nerd Font** (for icons) - Download from [nerdfonts.com](https://www.nerdfonts.com/)
- Recommended: `JetBrainsMono Nerd Font` or `FiraCode Nerd Font`

## Installation

1. **Backup existing config** (if any):
   ```bash
   mv ~/.config/nvim ~/.config/nvim.backup
   ```

2. **Clone this config**:
   ```bash
   git clone <your-repo-url> ~/.config/nvim
   ```

3. **Install plugins**:
   ```bash
   nvim
   ```
   Plugins will install automatically on first launch.

## Key Mappings

### General
- `<leader>` = `Space`
- `Ctrl+S` - Save file
- `Ctrl+Q` - Quit all
- `Ctrl+C` - Close current window
- `Esc` - Clear search highlight

### Window Navigation
- `Ctrl+H/J/K/L` - Navigate between windows
- `<leader>w + h/j/k/l` - Split windows

### File Management
- `<leader>e` - Toggle file tree
- `Ctrl+N` - Focus file tree

### Fuzzy Finding (Telescope)
- `<leader>ff` - Find files
- `<leader>fw` - Live grep (search text)
- `gd` - Go to definition
- `<leader>dt` - Show diagnostics

### Git Operations (Telescope + GitSigns)
- `<leader>gc` - Git commits (with diff preview)
- `<leader>gb` - Git branches
- `<leader>gs` - Git status (with diff preview)
- `<leader>gS` - Git stash
- `<leader>gd` - Git diff current file
- `<leader>gp` - Preview git hunk
- `<leader>gl` - Git blame line
- `<leader>hs` - Stage git hunk
- `<leader>hr` - Reset git hunk
- `]c` / `[c` - Next/Previous git hunk

### LSP Features
- `K` - Hover documentation
- `<leader>rn` - Rename symbol
- `<leader>ca` - Code actions
- `<leader>d` - Show diagnostics
- `<leader>dn/dN` - Next/Previous diagnostic
- `<leader>dy` - Copy diagnostic to clipboard
- `Ctrl+H` (in insert mode) - Signature help

### Code Movement
- `Ctrl+J/K` - Move lines up/down
- `Ctrl+H/L` - Indent/unindent

## File Structure

```
lua/
├── config/
│   ├── keymaps.lua     # Key mappings
│   ├── lazy.lua        # Plugin manager setup
│   └── settings.lua    # Neovim settings
├── plugins/
│   ├── catppuccin.lua  # Color scheme
│   ├── cmp.lua         # Autocompletion
│   ├── dashboard.lua   # Start screen
│   ├── gitsigns.lua    # Git integration and visual diff
│   ├── lsp.lua         # Language server setup
│   ├── lsp-signature.lua # Function signature help
│   ├── lualine.lua     # Status line
│   ├── neo-tree.lua    # File tree
│   └── telescope.lua   # Fuzzy finder
└── themes/
    └── *.lua          # Additional themes
```

## Customization

### Change Theme
Edit `lua/plugins/catppuccin.lua`:
```lua
flavour = "mocha" -- latte, frappe, macchiato, mocha
```

### Add Language Server
Edit `lua/plugins/lsp.lua`:
```lua
lspconfig.your_language_server.setup({ on_attach = on_attach })
```

### Add Formatter
Edit the `BufWritePost` autocmd in `lua/plugins/lsp.lua`

## Troubleshooting

### Icons not showing
- Install a Nerd Font and set it in your terminal
- Verify with: `echo "📁 📂 📄 ⚙️ 🚀"`

### LSP not working
- Check if language servers are installed: `:LspInfo`
- Install missing servers manually (see Requirements)

### Formatting not working
- Check if formatters are installed: `:!which ruff` or `:!which stylua`
- Install formatters manually (see Requirements)

### Plugin errors
- Update plugins: `:Lazy update`
- Check health: `:checkhealth`

## Contributing

Feel free to submit issues and improvements to this configuration.

## License

MIT License - feel free to use and modify as needed.