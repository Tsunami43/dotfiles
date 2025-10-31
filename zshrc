# ───────────────────────────────────────────────
# 📁 Dotfiles base path
# Used for config-related shortcuts and functions
export PATH_TO_DOTFILES="$HOME/dotfiles"

# ───────────────────────────────────────────────
# 🧠 Oh My Zsh initialization
export ZSH="$HOME/.oh-my-zsh"
source "$ZSH/oh-my-zsh.sh"

# Oh My Zsh plugins
# git -  Enhances Git with aliases, tab-completion, and status info
# history - Adds advanced history search and related aliases
# docker - Adds helpful aliases and completion for Docker commands
# zsh-autosuggestions - Suggests commands as you type based on your history (like fish shell)
# zsh-syntax-highlighting - Adds syntax highlighting to Zsh
plugins=(git docker history zsh-autosuggestions zsh-syntax-highlighting)

# History settings
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

setopt HIST_IGNORE_ALL_DUPS       # do not add duplicates
setopt HIST_REDUCE_BLANKS         # delete blank lines
setopt INC_APPEND_HISTORY         # write to the history file immediately
setopt SHARE_HISTORY              # share history between sessions
setopt APPEND_HISTORY             # add new history items to history file

# Syntax highlighting
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.zsh/catppuccin_mocha-zsh-syntax-highlighting.zsh
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

# ───────────────────────────────────────────────
# 🧱 Environment: Language & Toolchain Paths
export HOMEBREW_NO_ENV_HINTS=1

# scripts
export PATH="$HOME/bin:$PATH"

# Golang
export PATH="$PATH:$(go env GOPATH)/bin"

# poetry
export PATH="$HOME/.local/bin:$PATH"

# ───────────────────────────────────────────────
# 🖥️ Terminal Enhancements

# Starship prompt
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
eval "$(starship init zsh)"

# Zoxide (smart cd replacement)
eval "$(zoxide init zsh)"

# Tmux config path
export TMUX_CONF="$HOME/.config/tmux/tmux.conf"

# ───────────────────────────────────────────────
# ⚙️ Useful Aliases & Functions

# # Neovim/Helix config shortcut
# alias hxconf="hx $HOME/.config/helix"
# alias nvconf="nvim $HOME/.config/nvim"

# Yazi file manager wrapper (remembers last directory)
function yy() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

# Replacements and shortcuts
alias dotconf="nvim $PATH_TO_DOTFILES"
alias cat="bat --style=plain"
alias vi="nvim"
alias vim="nvim"
alias zshconf="nvim ~/dotfiles/.zshrc"
alias hosts="nvim ~/.ssh/config"
alias neofetch="fastfetch"

# Docker alias for Kali Linux container
alias kali="docker run -it leplusorg/kali bin/bash"

# Fancy ls
alias ls="eza -l --tree --level=1 --icons=always --no-user --no-permissions"

# AsyncAPI CLI Autocomplete

ASYNCAPI_AC_ZSH_SETUP_PATH=~/Library/Caches/@asyncapi/cli/autocomplete/zsh_setup && test -f $ASYNCAPI_AC_ZSH_SETUP_PATH && source $ASYNCAPI_AC_ZSH_SETUP_PATH; # asyncapi autocomplete setup

# pyenv
export PATH="$HOME/.pyenv/shims:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"


tmux() {
  if [ $# -eq 0 ]; then
    NAMES_FILE="$HOME/.config/tmux/session_names.txt"
    # Берём случайную строку без shuf
    LINES=($(<"$NAMES_FILE"))
    SESSION_NAME=${LINES[$((RANDOM % ${#LINES[@]} + 1))]}
    command tmux new-session -s "$SESSION_NAME"
  else
    command tmux "$@"
  fi
}
