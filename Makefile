DOTFILES_DIR := $(CURDIR)

# ANSI Colors
GREEN  := \033[1;32m
RED    := \033[1;31m
BLUE   := \033[1;34m
YELLOW := \033[1;33m
RESET  := \033[0m

# Symbols
CHECK  := ✔
FAIL   := ✘
ARROW  := →
DONE   := ✅

.PHONY: symlink install all

all:
	@echo "$(BLUE)$(ARROW) Starting full install...$(RESET)"
	@$(MAKE) symlink
	@$(MAKE) install

symlink:
	@echo "$(BLUE)$(ARROW) Creating symlinks...$(RESET)"
	@ln -sf $(DOTFILES_DIR)/zshrc $(HOME)/.zshrc
	@ln -sf $(DOTFILES_DIR)/config $(HOME)/.config
	@echo "$(GREEN)$(CHECK) Symlinks created.$(RESET)"

define INSTALL_BREW_PKG
	@echo "$(BLUE)$(ARROW) Checking $(1)...$(RESET) "
	@if brew list $(1) >/dev/null 2>&1; then \
		echo "$(GREEN)$(CHECK) Installed$(RESET)"; \
	else \
		echo "$(YELLOW)$(ARROW) Installing $(1)...$(RESET)"; \
		if brew install $(1) >/dev/null 2>&1; then \
			echo "$(GREEN)$(CHECK) $(1) installed$(RESET)"; \
		else \
			echo "$(RED)$(FAIL) Failed to install $(1)$(RESET)"; \
		fi; \
	fi
endef

install:
	@echo "$(BLUE)$(ARROW) Installing packages...$(RESET)"

	@if ! command -v brew >/dev/null 2>&1; then \
		echo "$(YELLOW)$(ARROW) Installing Homebrew...$(RESET)"; \
		/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" && \
		echo "$(GREEN)$(CHECK) Homebrew installed$(RESET)" || \
		echo "$(RED)$(FAIL) Homebrew install failed$(RESET)"; \
	else \
		echo "$(GREEN)$(CHECK) Homebrew already installed$(RESET)"; \
	fi

	# Brew packages
	$(call INSTALL_BREW_PKG,git)
	$(call INSTALL_BREW_PKG,zip)
	$(call INSTALL_BREW_PKG,unzip)
	$(call INSTALL_BREW_PKG,curl)
	$(call INSTALL_BREW_PKG,zsh)
	$(call INSTALL_BREW_PKG,htop)
	$(call INSTALL_BREW_PKG,aerospace)
	$(call INSTALL_BREW_PKG,fastfetch)
	$(call INSTALL_BREW_PKG,ghostty)
	$(call INSTALL_BREW_PKG,starship)
	$(call INSTALL_BREW_PKG,yazi)
	$(call INSTALL_BREW_PKG,zoxide)
	$(call INSTALL_BREW_PKG,eza)
	$(call INSTALL_BREW_PKG,neovim)
	$(call INSTALL_BREW_PKG,tmux)
	$(call INSTALL_BREW_PKG,bat)
	$(call INSTALL_BREW_PKG,node)
	$(call INSTALL_BREW_PKG,uv)
	$(call INSTALL_BREW_PKG,pyenv)


	@echo "$(BLUE)$(ARROW) Installing Oh My Zsh & Plugins...$(RESET)"
	@if [ -d "$(HOME)/.oh-my-zsh" ]; then \
		echo "$(GREEN)$(CHECK) Oh My Zsh already installed$(RESET)"; \
	else \
		echo "$(YELLOW)$(ARROW) Installing Oh My Zsh...$(RESET)"; \
		if sh -c "$$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended >/dev/null 2>&1; then \
			echo "$(GREEN)$(CHECK) Oh My Zsh installed$(RESET)"; \
		else \
			echo "$(RED)$(FAIL) Oh My Zsh install failed$(RESET)"; \
		fi; \
	fi

	@if [ -d "$(HOME)/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then \
		echo "$(GREEN)$(CHECK) zsh-autosuggestions already installed$(RESET)"; \
	else \
		echo "$(YELLOW)$(ARROW) Installing zsh-autosuggestions...$(RESET)"; \
		if git clone https://github.com/zsh-users/zsh-autosuggestions.git $(HOME)/.oh-my-zsh/custom/plugins/zsh-autosuggestions >/dev/null 2>&1; then \
			echo "$(GREEN)$(CHECK) zsh-autosuggestions installed$(RESET)"; \
		else \
			echo "$(RED)$(FAIL) Failed to install zsh-autosuggestions$(RESET)"; \
		fi; \
	fi


	@if [ -d "$(HOME)/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then \
		echo "$(GREEN)$(CHECK) zsh-syntax-highlighting already installed$(RESET)"; \
	else \
		echo "$(YELLOW)$(ARROW) Installing zsh-syntax-highlighting...$(RESET)"; \
		if git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $(HOME)/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting >/dev/null 2>&1; then \
			echo "$(GREEN)$(CHECK) zsh-syntax-highlighting installed$(RESET)"; \
		else \
			echo "$(RED)$(FAIL) Failed to install zsh-syntax-highlighting$(RESET)"; \
		fi; \
	fi


	@echo "$(BLUE)$(ARROW) Checking poetry...$(RESET) "
	@if command -v poetry >/dev/null 2>&1; then \
		echo "$(GREEN)$(CHECK) Installed$(RESET)"; \
	else \
		echo "$(YELLOW)$(ARROW) Installing poetry...$(RESET)"; \
		if curl -sSL https://install.python-poetry.org | python3 - >/dev/null 2>&1; then \
			echo "$(GREEN)$(CHECK) poetry installed$(RESET)"; \
		else \
			echo "$(RED)$(FAIL) Failed to install poetry$(RESET)"; \
		fi; \
	fi


	@echo "$(BLUE)$(ARROW) Checking rustup...$(RESET) "
	@if command -v rustup >/dev/null 2>&1; then \
		echo "$(GREEN)$(CHECK) Installed$(RESET)"; \
	else \
		echo "$(YELLOW)$(ARROW) Installing rustup...$(RESET)"; \
		if curl https://sh.rustup.rs -sSf | sh -s -- -y >/dev/null 2>&1; then \
			echo "$(GREEN)$(CHECK) rustup installed$(RESET)"; \
		else \
			echo "$(RED)$(FAIL) Failed to install rustup$(RESET)"; \
		fi; \
	fi
	

	@echo ""
	@echo "$(GREEN)=======================================$(RESET)"
	@echo "$(GREEN)$(CHECK) All tools installed successfully.$(RESET)"
	@echo "$(GREEN)=======================================$(RESET)"
