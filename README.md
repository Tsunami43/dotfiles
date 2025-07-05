# 🛠️ dotfiles

My personal dotfiles for macOS and Linux, including shell, editor, and CLI tool configurations.

---

## 📁 Contents

| File / Directory     | Purpose                                 |
|----------------------|------------------------------------------|
| `.zshrc`             | Main Zsh shell configuration             |
| `.p10k.zsh`          | Powerlevel10k theme config (optional)    |
| `.gitconfig`         | Git global config                        |
| `.config/`           | App configs (`nvim`, `tmux`, `starship`, `aerospace`, etc.) |
| `Makefile`           | Automates installation & symlinking      |

---

## ⚙️ Setup

### 1. Clone this repo

```bash
git clone https://github.com/your-username/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 2. Install
```bash
make
```

## 📦 Tools Installed

Automatically installs (depending on your OS):

* Shell: zsh, oh-my-zsh, powerlevel10k or starship

* Editors/CLI: neovim, tmux, bat, eza, yazi, ghostty

* Utilities: git, zip, unzip, node, npm

* Python: pyenv (for managing Python versions)

* macOS tiling manager: aerospace (via npm — install manually if needed)
