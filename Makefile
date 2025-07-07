DOTFILES_DIR := $(CURDIR)
BIN_DIR := $(HOME)/bin
SCRIPTS_DIR := $(DOTFILES_DIR)/scripts

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

.PHONY: symlink install symlink-scripts all


all:
	@echo "$(BLUE)$(ARROW) Starting full install...$(RESET)"
	@$(MAKE) symlink
	@$(MAKE) install
	@$(MAKE) symlink-scripts


symlink-scripts:
	@echo "$(BLUE)$(ARROW) Creating symlinks for scripts in $(BIN_DIR)...$(RESET)"
	@mkdir -p $(BIN_DIR)
	@for script in $(SCRIPTS_DIR)/*.sh; do \
		name=$$(basename $$script .sh); \
		ln -sf $$script $(BIN_DIR)/$$name; \
		chmod +x $$script; \
		echo "$(GREEN)🔗 Linked $$script as $(BIN_DIR)/$$name$(RESET)"; \
	done
	@echo "$(GREEN)$(CHECK) All script symlinks created.$(RESET)"

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
	$(call INSTALL_BREW_PKG,zsh-syntax-highlighting)


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


	$(call INSTALL_BREW_PKG,htop)
	$(call INSTALL_BREW_PKG,aerospace)
	$(call INSTALL_BREW_PKG,fastfetch)
	$(call INSTALL_BREW_PKG,ghostty)
	$(call INSTALL_BREW_PKG,starship)
	$(call INSTALL_BREW_PKG,yazi)
	$(call INSTALL_BREW_PKG,zoxide)
	$(call INSTALL_BREW_PKG,eza)
	$(call INSTALL_BREW_PKG,node)
	$(call INSTALL_BREW_PKG,neovim)
	$(call INSTALL_BREW_PKG,tmux)
	$(call INSTALL_BREW_PKG,bat)


	$(call INSTALL_BREW_PKG,uv)
	$(call INSTALL_BREW_PKG,pyenv)

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


	@echo ""
	@echo "$(GREEN)=======================================$(RESET)"
	@echo "$(GREEN)$(CHECK) All tools installed successfully.$(RESET)"
	@echo "$(GREEN)=======================================$(RESET)"
