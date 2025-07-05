DOTFILES_DIR := $(shell pwd)

.PHONY: symlink install

symlink:
	@echo "🔗 Creating symlinks..."
	ln -sf $(DOTFILES_DIR)/.zshrc $(HOME)/.zshrc
	ln -sf $(DOTFILES_DIR)/.p10k.zsh $(HOME)/.p10k.zsh
	ln -sf $(DOTFILES_DIR)/.gitconfig $(HOME)/.gitconfig
	ln -sf $(DOTFILES_DIR)/.config $(HOME)/.config
	@echo "✅ Symlinks created."

install:
	@echo "💻 Detecting OS and installing packages..."
	@if [ "$$(uname)" = "Darwin" ]; then \
		echo "🖥 macOS detected"; \
		if ! command -v brew >/dev/null 2>&1; then \
			echo "🔧 Homebrew not found, installing..."; \
			/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
		fi; \
		echo "📦 Installing CLI packages via brew..."; \
		brew install git zsh zip unzip tmux bat neovim node eza yazi starship ghostty pyenv htop neofetch; \
		echo "🎀 Installing Oh My Zsh..."; \
		[ -d $$HOME/.oh-my-zsh ] || sh -c "$$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; \
	elif [ -f /etc/debian_version ]; then \
		echo "🐧 Debian-based Linux detected"; \
		sudo apt-get update; \
		sudo apt-get install -y git zsh zip unzip tmux bat neovim nodejs npm curl unzip htop neofetch; \
		echo "🎀 Installing Oh My Zsh..."; \
		[ -d $$HOME/.oh-my-zsh ] || sh -c "$$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; \
		echo "🟢 Installing Ghostty..."; \
		curl -sSfL https://github.com/ghostty-org/ghostty/releases/latest/download/ghostty-x86_64-unknown-linux-gnu.zip -o /tmp/ghostty.zip && \
		unzip -o /tmp/ghostty.zip -d /tmp/ghostty && \
		sudo install /tmp/ghostty/ghostty /usr/local/bin/ghostty; \
		echo "🐍 Installing pyenv..."; \
		git clone https://github.com/pyenv/pyenv.git $$HOME/.pyenv; \
	else \
		echo "❌ Unsupported OS. Please install packages manually."; \
	fi
	@echo "✅ Installation complete!"
